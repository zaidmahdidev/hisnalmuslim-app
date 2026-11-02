# Content Guidelines

The religious content is the heart of this app. These rules are mandatory.

## Non-negotiable rules

1. **Never type religious text from memory.** No Quran, hadith, dua or
   virtue is ever written by hand into code, JSON or translations. Text comes
   only from the sources below, through the build scripts.
2. Never fabricate or paraphrase a hadith, verse, virtue or attribution.
3. Preserve the original Arabic wording. Only *typographic* clean-up is
   allowed (see below) and it is applied by code, not by hand.
4. Every item must be traceable to its source (`source` field).
5. Distinguish Quran from Sunnah (`kind`); Quranic passages are shown in
   the Quranic typeface.
6. If a reference is not reliably available, leave it empty — the app then
   says "reference not yet attached" — and list it for review.
7. Do not claim the content has been reviewed by a scholar until it has.

## Current review status

The content was assembled and cross-checked **programmatically**
(2026-11-01). It has **not** been reviewed by a qualified scholar. The app
states this on the About and Content Sources screens. Before or soon after
launch, a qualified reviewer should go through
[content/CONTENT_VERIFICATION_REPORT.md](content/CONTENT_VERIFICATION_REPORT.md).

## Sources

| Data | Source | File in `tool/content/sources/` |
|---|---|---|
| Arabic text, repeat count, chapter titles | Official Hisn al-Muslim API, hisnmuslim.com (`/api/ar/*.json`) | `hisnmuslim_ar.json` |
| English translation & transliteration, English chapter titles | hisnmuslim.com (`/api/en/*.json`) | `hisnmuslim_en.json` |
| Book footnotes (takhrij + virtue) | Text transcription of the book, github.com/rn0x/hisn_almuslim_json | `rn0x_hisn_almuslim.json` |
| Evening wording of morning/evening adhkar | github.com/osamayy/azkar-db (only when it matches the book's note) | `osamayy_azkar_db.json` |
| Quranic supplications | Tanzil "quran-simple" text + Saheeh International via api.alquran.cloud | `quran_duas_tanzil.json` |

Only the *references* (surah:ayah) of the Quranic supplications are curated
by hand (`tool/content/fetch_quran.py`). Whole verses are always used, never
trimmed.

### Licensing — requires the publisher's confirmation

- *Hisn al-Muslim* is widely distributed free of charge and hisnmuslim.com
  publishes a public API for developers, but no explicit licence text was
  found. **Confirm permission/terms with the copyright holder or the site
  before commercial distribution.**
- The rn0x and osamayy repositories publish no licence file. Their data is
  used only for footnote alignment and evening wording; consider asking the
  maintainers or replacing them with a licensed edition.
- Tanzil text is free to use with attribution and without modification
  (tanzil.net terms) — the app attributes it on the Sources screen.
  **Saheeh International** is copyrighted (Dar Abul-Qasim); its use in free
  apps is common, but confirm the terms or switch to a public-domain
  translation for the Quranic section.
- Fonts are SIL OFL 1.1 (licence files bundled and shown in the app).

## How the database is built (`tool/content/build_content.py`)

1. Chapters of the official API are mapped to the 13 app categories
   (`CATEGORIES`). The script asserts every chapter is mapped exactly once.
2. **Text & repeat**: verbatim from the official API. If the API `REPEAT`
   contradicts a count stated *after* the quoted dhikr (e.g.
   `…العظيم)) (سبع مرات).`), the stated count is used and logged. Counts that
   apply to a phrase inside the dhikr or describe a narration are ignored.
3. **Morning/evening**: items saying "إذا أصبح" are morning-only, "إذا أمسى"
   evening-only. The book gives evening wording as notes `[وإذا أمسى قال: …]`;
   the evening text is taken from azkar-db **only if it contains every note
   phrase**, otherwise the morning text is shown with the book's note. The
   note is always kept in the item's `note` field.
4. **Footnotes**: the transcription's footnotes are attached when alignment
   is unambiguous (equal counts, or equal counts after dropping footnotes
   without any source), or via the hand-reviewed `MANUAL_ALIGNMENT` table
   (chapters 27 and 13). Footnote text is shown verbatim; short reference
   chips (`refs`) are derived from it (primary sources only).
5. **Known API defects** are overridden from the book transcription and
   flagged (`TRANSCRIPTION_OVERRIDES`; currently chapter 86, whose API item
   duplicates chapter 87).
6. **Typographic clean-up only**: Arabic presentation forms → standard
   letters, tatweel removed, orphan diacritics removed, whitespace
   normalised. Chapter-heading typos are fixed by an explicit table
   (`TITLE_FIXES_*`), never adhkar text.
7. Output: `assets/content/adhkar.json` and the verification report.

## Data model (`assets/content/adhkar.json`)

```jsonc
{
  "version": 1,
  "sources": [...],
  "categories": [{"id","order","icon","titleAr","titleEn","subtitleAr","subtitleEn"}],
  "items": [{
    "id": "hm77.pm",            // stable id (favorites/progress depend on it)
    "categoryId": "evening",
    "order": 2,
    "sectionAr": "أذكار الصباح والمساء", "sectionEn": "...",
    "text": "...",              // Arabic, verbatim
    "note": "...",              // the book's note, if any
    "repeat": 1,
    "kind": "sunnah",           // or "quran"
    "footnote": "مسلم 4/ 2088", // the book's footnote verbatim
    "refs": [{"ar":"مسلم","en":"Muslim"}],
    "translation": "...", "translationSource": "hisnmuslim.com",
    "transliteration": "...",
    "source": "hisnmuslim:77",
    "flags": ["evening_text_from_dataset"]
  }]
}
```

## Changing content

1. Update a source file or a mapping in the build script — never the JSON.
2. `python tool/content/build_content.py`
3. Read the regenerated report and the diff of `adhkar.json`.
4. `flutter test` — `test/data/content_repository_test.dart` checks
   integrity (13 categories, non-empty text, repeat ≥ 1, traceable source,
   ordered items, Quran marked as Quran, evening wording, ≥ 95% referenced).
5. Keep ids stable. If an item must be removed, users' favorites for it are
   silently skipped (`ContentRepository.resolve`).
6. Bump `CONTENT_VERSION` and describe the change in the release notes.

## Reporting errors

Users are invited (About screen) to report mistakes. Set
`AppInfo.supportEmail` in `lib/core/constants/app_info.dart` to show a
contact address in the app.
