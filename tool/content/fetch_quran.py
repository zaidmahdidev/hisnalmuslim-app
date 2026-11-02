"""Fetch the Quranic supplications used by the app from api.alquran.cloud.

Only *references* (surah:ayah) are curated by hand here. The Arabic text is
downloaded verbatim from the Tanzil "quran-simple" edition and the English
meaning from Saheeh International ("en.sahih"). No Quranic text is typed
manually anywhere in this project.

Usage:  python tool/content/fetch_quran.py
Output: tool/content/sources/quran_duas_tanzil.json
"""

import io
import json
import os
import subprocess

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(HERE, "sources", "quran_duas_tanzil.json")

# (surah, first ayah, last ayah). Passages are kept whole: verses are never
# trimmed, so a dua that starts mid-verse is shown with its full verse.
PASSAGES = [
    (1, 1, 7),
    (2, 127, 128),
    (2, 201, 201),
    (2, 250, 250),
    (2, 286, 286),
    (3, 8, 9),
    (3, 16, 16),
    (3, 38, 38),
    (3, 53, 53),
    (3, 147, 147),
    (3, 191, 194),
    (7, 23, 23),
    (7, 126, 126),
    (7, 151, 151),
    (10, 85, 86),
    (11, 47, 47),
    (12, 101, 101),
    (14, 40, 41),
    (17, 24, 24),
    (17, 80, 80),
    (18, 10, 10),
    (20, 25, 28),
    (20, 114, 114),
    (21, 83, 83),
    (21, 87, 87),
    (21, 89, 89),
    (23, 29, 29),
    (23, 97, 98),
    (23, 109, 109),
    (23, 118, 118),
    (25, 65, 66),
    (25, 74, 74),
    (26, 83, 85),
    (27, 19, 19),
    (28, 16, 16),
    (28, 24, 24),
    (29, 30, 30),
    (37, 100, 100),
    (46, 15, 15),
    (59, 10, 10),
    (60, 5, 5),
    (71, 28, 28),
]

EDITIONS = "quran-simple,en.sahih"


def fetch(url):
    out = subprocess.run(
        ["curl", "-sS", "-m", "40", "-A", "Mozilla/5.0", url],
        capture_output=True,
        check=True,
    ).stdout
    return json.loads(out.decode("utf-8"))


def main():
    result = {
        "source": "https://api.alquran.cloud/v1 (Tanzil quran-simple, Saheeh International en.sahih)",
        "passages": [],
    }
    for surah, start, end in PASSAGES:
        ayahs = []
        meta = None
        for ayah in range(start, end + 1):
            data = fetch(f"https://api.alquran.cloud/v1/ayah/{surah}:{ayah}/editions/{EDITIONS}")
            if data.get("code") != 200:
                raise SystemExit(f"Failed {surah}:{ayah}: {data}")
            ar, en = data["data"]
            assert ar["edition"]["identifier"] == "quran-simple"
            assert en["edition"]["identifier"] == "en.sahih"
            meta = ar["surah"]
            ayahs.append({"number": ayah, "ar": ar["text"], "en": en["text"]})
        result["passages"].append(
            {
                "surah": surah,
                "surahNameAr": meta["name"],
                "surahNameEn": meta["englishName"],
                "from": start,
                "to": end,
                "ayahs": ayahs,
            }
        )
        print(f"ok {surah}:{start}-{end}")
    with io.open(OUT, "w", encoding="utf-8") as f:
        json.dump(result, f, ensure_ascii=False, indent=1)


if __name__ == "__main__":
    main()
