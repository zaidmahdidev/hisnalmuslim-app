"""Upload a release and the store listing to Google Play (Play Developer API v3).

Usage:
  python tool/release/play_publish.py --key PATH_TO_SERVICE_ACCOUNT.json [--track internal]

Everything happens in a single Play "edit" that is committed at the end:
  1. upload build/app/outputs/bundle/release/app-release.aab
  2. assign it to the track with AR/EN release notes
  3. update the ar + en-US listings from docs/release/APP_DESCRIPTION_*.md
  4. replace icon, feature graphic and phone screenshots per language

Apps that have never been published only accept releases with status
"draft"; the script falls back to that automatically and says so.
The service-account key must never be committed (see .gitignore).
"""

import argparse
import glob
import io
import os
import re
import sys

from google.oauth2 import service_account
from googleapiclient.discovery import build
from googleapiclient.errors import HttpError
from googleapiclient.http import MediaFileUpload

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
PACKAGE = "com.zaid.hisnalmuslim"
AAB = os.path.join(ROOT, "build", "app", "outputs", "bundle", "release", "app-release.aab")
DOCS = os.path.join(ROOT, "docs", "release")
ASSETS = os.path.join(DOCS, "store_assets")

# Play language code -> (description file, marker, screenshot prefix, notes file)
LANGUAGES = {
    "ar": ("APP_DESCRIPTION_AR.md", "AR", "ar_", "RELEASE_NOTES_AR.md"),
    "en-US": ("APP_DESCRIPTION_EN.md", "EN", "en_", "RELEASE_NOTES_EN.md"),
}


def read(path):
    with io.open(path, encoding="utf-8") as f:
        return f.read()


def first_line_after(text, heading_prefix):
    lines = text.split("\n")
    i = next(k for k, l in enumerate(lines) if l.startswith(heading_prefix))
    return next(l.strip() for l in lines[i + 1 :] if l.strip())


def listing_for(lang):
    doc, marker, _, _ = LANGUAGES[lang]
    text = read(os.path.join(DOCS, doc))
    headings = text.split("\n## ")
    title = first_line_after(text, "## " + headings[1].split("\n")[0])
    short = first_line_after(text, "## " + headings[2].split("\n")[0])
    full = text.split(f"<!-- FULL_{marker}_START -->")[1].split(f"<!-- FULL_{marker}_END -->")[0].strip()
    assert len(title) <= 30 and len(short) <= 80 and len(full) <= 4000, (lang, len(title), len(short), len(full))
    return {"language": lang, "title": title, "shortDescription": short, "fullDescription": full}


def release_notes(lang):
    text = read(os.path.join(DOCS, LANGUAGES[lang][3]))
    notes = re.search(r"```\n(.*?)\n```", text, re.S).group(1).strip()
    assert len(notes) <= 500, (lang, len(notes))
    return {"language": lang, "text": notes}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--key", required=True)
    parser.add_argument("--track", default="internal")
    parser.add_argument("--skip-bundle", action="store_true", help="only update listing/graphics")
    args = parser.parse_args()

    creds = service_account.Credentials.from_service_account_file(
        args.key, scopes=["https://www.googleapis.com/auth/androidpublisher"]
    )
    svc = build("androidpublisher", "v3", credentials=creds, cache_discovery=False)
    edits = svc.edits()
    edit_id = edits.insert(packageName=PACKAGE, body={}).execute()["id"]
    print("edit", edit_id)

    try:
        if not args.skip_bundle:
            print("uploading bundle ...")
            bundle = edits.bundles().upload(
                packageName=PACKAGE,
                editId=edit_id,
                media_body=MediaFileUpload(AAB, mimetype="application/octet-stream", resumable=True),
            ).execute()
            version_code = bundle["versionCode"]
            print("  versionCode", version_code)

            release = {
                "name": f"{version_code}",
                "versionCodes": [str(version_code)],
                "releaseNotes": [release_notes(l) for l in LANGUAGES],
                "status": "completed",
            }
            try:
                edits.tracks().update(
                    packageName=PACKAGE, editId=edit_id, track=args.track,
                    body={"track": args.track, "releases": [release]},
                ).execute()
            except HttpError as e:
                if "draft" not in e.content.decode().lower():
                    raise
                print("  app not published yet -> creating the release as DRAFT")
                release["status"] = "draft"
                edits.tracks().update(
                    packageName=PACKAGE, editId=edit_id, track=args.track,
                    body={"track": args.track, "releases": [release]},
                ).execute()
            print(f"  track '{args.track}': {release['status']}")

        for lang in LANGUAGES:
            body = listing_for(lang)
            edits.listings().update(packageName=PACKAGE, editId=edit_id, language=lang, body=body).execute()
            print(f"listing {lang}: '{body['title']}'")

            prefix = LANGUAGES[lang][2]
            uploads = [
                ("icon", [os.path.join(ASSETS, "play_store_icon_512.png")]),
                ("featureGraphic", [os.path.join(ASSETS, "feature_graphic", f"feature_graphic_{prefix[:2]}.png")]),
                ("phoneScreenshots", sorted(glob.glob(os.path.join(ASSETS, "screenshots", f"{prefix}*.png")))),
            ]
            for image_type, files in uploads:
                edits.images().deleteall(
                    packageName=PACKAGE, editId=edit_id, language=lang, imageType=image_type
                ).execute()
                for f in files:
                    edits.images().upload(
                        packageName=PACKAGE, editId=edit_id, language=lang, imageType=image_type,
                        media_body=MediaFileUpload(f, mimetype="image/png"),
                    ).execute()
                print(f"  {image_type}: {len(files)}")

        edits.commit(packageName=PACKAGE, editId=edit_id).execute()
        print("COMMITTED")
    except HttpError as e:
        print("HTTP", e.resp.status, e.content.decode()[:1500])
        try:
            edits.delete(packageName=PACKAGE, editId=edit_id).execute()
            print("edit discarded (nothing changed on Play)")
        except HttpError:
            pass
        sys.exit(1)


if __name__ == "__main__":
    main()
