"""Build the app's bundled content database (assets/content/adhkar.json).

Pipeline (every decision is recorded in the verification report):

1. Text and repetition count come verbatim from the official Hisn al-Muslim
   API (hisnmuslim.com). Nothing is paraphrased.
2. The book's footnotes (takhrij, often including the virtue) come from the
   rn0x/hisn_almuslim_json transcription. A footnote is attached to an item
   only when the alignment is unambiguous; otherwise it is left empty and
   flagged for review.
3. For the morning/evening chapter the book gives evening wording as notes
   ("وإذا أمسى قال: ..."). The evening text is taken from osamayy/azkar-db
   only if it contains every evening note phrase; otherwise the morning text
   is kept together with the book's note and the item is flagged.
4. English translation/transliteration come from the official English API.
5. Quranic supplications come from Tanzil (see fetch_quran.py).

Usage:  python tool/content/build_content.py
"""

import io
import json
import os
import re
import unicodedata
from collections import Counter, OrderedDict
from difflib import SequenceMatcher

HERE = os.path.dirname(os.path.abspath(__file__))
SRC = os.path.join(HERE, "sources")
ROOT = os.path.abspath(os.path.join(HERE, "..", ".."))
OUT_JSON = os.path.join(ROOT, "assets", "content", "adhkar.json")
OUT_REPORT = os.path.join(ROOT, "docs", "content", "CONTENT_VERIFICATION_REPORT.md")

CONTENT_VERSION = 1

# --------------------------------------------------------------------------
# Category map (official chapter IDs). Order inside a category follows the
# order given here, then the book's own item order.
# --------------------------------------------------------------------------
CATEGORIES = [
    dict(id="morning", icon="morning", chapters=[27], variant="am",
         ar="أذكار الصباح", en="Morning Adhkar",
         sub_ar="تُقال بعد صلاة الفجر حتى طلوع الشمس", sub_en="From Fajr until sunrise"),
    dict(id="evening", icon="evening", chapters=[27], variant="pm",
         ar="أذكار المساء", en="Evening Adhkar",
         sub_ar="تُقال بعد صلاة العصر حتى غروب الشمس", sub_en="From Asr until sunset"),
    dict(id="sleep", icon="sleep", chapters=[28, 29, 30, 31],
         ar="أذكار النوم", en="Before Sleeping",
         sub_ar="عند النوم وإذا تقلّب أو فزع ليلاً", sub_en="At bedtime and during the night"),
    dict(id="waking", icon="waking", chapters=[1],
         ar="أذكار الاستيقاظ", en="Upon Waking Up",
         sub_ar="عند الاستيقاظ من النوم", sub_en="When you wake up"),
    dict(id="after_prayer", icon="after_prayer", chapters=[25],
         ar="أذكار بعد الصلاة", en="After Prayer",
         sub_ar="بعد السلام من الصلاة المفروضة", sub_en="After completing the obligatory prayer"),
    dict(id="prayer", icon="prayer", chapters=[16, 17, 18, 19, 20, 21, 22, 23, 24, 26, 32, 33],
         ar="أذكار الصلاة", en="Prayer Adhkar",
         sub_ar="الاستفتاح والركوع والسجود والتشهد والوتر", sub_en="Opening, bowing, prostration, tashahhud, witr"),
    dict(id="mosque", icon="mosque", chapters=[12, 13, 14, 15],
         ar="أذكار المسجد", en="Mosque & Adhan",
         sub_ar="الذهاب إلى المسجد ودخوله والخروج منه والأذان", sub_en="Going to, entering and leaving the mosque; the adhan"),
    dict(id="food", icon="food", chapters=[69, 70, 71, 72, 68, 73, 74, 75, 76],
         ar="أذكار الطعام والشراب", en="Food & Drink",
         sub_ar="قبل الطعام وبعده والصيام والضيافة", sub_en="Before and after eating, fasting and hospitality"),
    dict(id="home", icon="home", chapters=[10, 11, 2, 3, 4, 5, 6, 7, 8, 9],
         ar="أذكار المنزل", en="Home & Daily Life",
         sub_ar="الخروج والدخول واللباس والخلاء والوضوء", sub_en="Leaving and entering, clothing, restroom, ablution"),
    dict(id="travel", icon="travel", chapters=[95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105],
         ar="أذكار السفر", en="Travel",
         sub_ar="الركوب والسفر والرجوع منه", sub_en="Riding, travelling and returning"),
    dict(id="quran_duas", icon="quran", chapters=[], source="tanzil",
         ar="الأدعية من القرآن الكريم", en="Supplications from the Quran",
         sub_ar="أدعية وردت في آيات القرآن الكريم", sub_en="Supplications found in the verses of the Quran"),
    dict(id="prophetic_duas", icon="prophetic",
         chapters=[34, 35, 41, 43, 44, 36, 37, 38, 39, 40, 42, 45, 46, 129, 130, 131, 107],
         ar="الأدعية النبوية", en="Prophetic Supplications",
         sub_ar="الهمّ والكرب والدَّين والاستغفار والتسبيح", sub_en="Worry, distress, debt, forgiveness and glorification"),
    dict(id="misc", icon="misc",
         chapters=list(range(47, 68)) + list(range(77, 95)) + [106] + list(range(108, 129)) + [132],
         ar="أذكار متنوعة", en="Various Adhkar",
         sub_ar="المرض والمطر والمناسبات والحج والآداب", sub_en="Illness, weather, occasions, Hajj and etiquette"),
]

# Typographical fixes for chapter *headings* only (never applied to adhkar).
TITLE_FIXES_AR = {
    "مترلا": "منزلا",          # OCR error in the source PDF (ز ل -> تر)
    "دعاء ُلبْس": "دعاء لُبْس",  # misplaced damma
    "أو ُ غلب": "أو غُلب",       # misplaced damma
}
TITLE_FIXES_EN = {
    "vocation for someone": "Invocation for someone",
    "when it thunder": "when it thunders",
    "stricken by in your faith": "stricken by doubt in your faith",
    "setting of a debt": "settling of a debt",
    "supplications for when you wake up": "Supplications for when you wake up",
}

# Chapters whose official API data is known to be defective. Their items are
# taken verbatim from the book transcription (text + footnote) instead.
#   86: the API reuses item 198 ("جزاك الله خيراً") from chapter 87; the book
#       gives "ولك" (Ahmad 5/28, an-Nasa'i in 'Amal al-Yawm wal-Laylah 421).
TRANSCRIPTION_OVERRIDES = {86: "الدعاء لمن قال غفر الله لك"}

# Chapter titles that differ between the official API and the transcription.
FOOTNOTE_TITLE_MAP = {
    23: "الصلاة على النبي صلى الله عليه وسلم بعد التشهد",
    85: "كفارة المجلس ومايختم به المجالس",
    131: "كيف كان النبي صلى الله عليه وسلم يسبح ؟",
}

# Hand-reviewed alignment for chapters where counting footnotes is ambiguous:
# {chapter: {transcription text index: [footnote indices]}}. Footnotes that
# only repeat the evening wording (already part of the official text), word
# glosses, and the chapter introduction's footnote are deliberately omitted.
MANUAL_ALIGNMENT = {
    27: {1: [1], 2: [2], 3: [5], 4: [7], 5: [9], 6: [11], 7: [13], 8: [14],
         9: [15], 10: [16], 11: [17], 12: [18], 13: [19], 14: [20], 15: [23],
         16: [25], 17: [26], 18: [27, 28], 19: [29], 20: [30], 21: [31],
         22: [32], 23: [33], 24: [34]},
    13: {0: [0], 1: [1, 2, 3]},
}

# Collections recognised inside footnotes -> (Arabic label, English label).
COLLECTIONS = [
    (r"البخاري", "البخاري", "Al-Bukhari"),
    (r"(?<![\u0621-\u064A])و?مسلم(?![\u0621-\u064A])", "مسلم", "Muslim"),
    (r"أب[وي] داود|ابو داود", "أبو داود", "Abu Dawud"),
    (r"الترمذي", "الترمذي", "At-Tirmidhi"),
    (r"النسائي", "النسائي", "An-Nasa'i"),
    (r"ابن ماج[هة]", "ابن ماجه", "Ibn Majah"),
    (r"(?<![\u0621-\u064A])و?أحمد(?![\u0621-\u064A])", "أحمد", "Ahmad"),
    (r"أصحاب السنن", "أصحاب السنن", "Sunan compilers"),
    (r"الحاكم", "الحاكم", "Al-Hakim"),
    (r"الطبراني", "الطبراني", "At-Tabarani"),
    (r"ابن السني", "ابن السني", "Ibn as-Sunni"),
    (r"الموطأ|(?<![\u0621-\u064A])مالك(?![\u0621-\u064A])", "مالك", "Malik"),
    (r"البيهقي", "البيهقي", "Al-Bayhaqi"),
    (r"الدارمي", "الدارمي", "Ad-Darimi"),
    (r"ابن حبان", "ابن حبان", "Ibn Hibban"),
    (r"ابن أبي شيبة", "ابن أبي شيبة", "Ibn Abi Shaybah"),
    (r"عبد الرزاق", "عبد الرزاق", "Abd ar-Razzaq"),
    (r"البزار", "البزار", "Al-Bazzar"),
    (r"الدارقطني", "الدارقطني", "Ad-Daraqutni"),
]
SOURCE_HINT = re.compile(
    "|".join(c[0] for c in COLLECTIONS) + r"|سورة|صحيح|الألباني|رواه|أخرجه|متفق عليه|برقم"
)

COUNT_WORDS = [
    (r"مائ?ة مر|مئة مر", 100),
    (r"ثلاث[ا\u064B\u064E]* وثلاثين", 33),
    (r"عشر مرات|عشر مرّات", 10),
    (r"سبع مرات|سبع مرّات", 7),
    (r"أربع مرات|أربع مرّات", 4),
    (r"ثلاث[\u064E]? ?مر[\u064E\u0651]?ات|ثلاثا\u064B|ثلاثا(?![\u0621-\u064A])", 3),
]

ARABIC_DIACRITICS = re.compile(r"[\u064B-\u065F\u0670\u0640\u06D6-\u06ED\uFEFF]")


def fix_presentation_forms(s):
    """NFKC-normalise only Arabic presentation-form code points."""
    return "".join(
        unicodedata.normalize("NFKC", c) if 0xFB50 <= ord(c) <= 0xFEFF and c != "\uFEFF" else c
        for c in s
    ).replace("\uFEFF", "")


def norm(s):
    s = fix_presentation_forms(s)
    s = ARABIC_DIACRITICS.sub("", s)
    s = re.sub("[أإآٱ]", "ا", s)
    s = s.replace("ى", "ي").replace("ة", "ه").replace("ؤ", "و").replace("ئ", "ي")
    s = re.sub(r"[^\u0621-\u064A\s]", " ", s)
    return re.sub(r"\s+", " ", s).strip()


def sim(a, b):
    return SequenceMatcher(None, a, b, autojunk=False).ratio()


def coverage(part, whole):
    """Share of `part` found inside `whole` (for items merged in the API)."""
    if len(part) < 12:
        return 0.0
    blocks = SequenceMatcher(None, part, whole, autojunk=False).get_matching_blocks()
    return sum(b.size for b in blocks if b.size >= 4) / len(part)


def clean_text(s):
    """Typographic clean-up only: presentation forms, tatweel, orphan marks."""
    s = fix_presentation_forms(s)
    s = s.replace("\u0640", "")
    s = re.sub(r"(?<=\s)[\u064B-\u0652]+", "", s)
    s = s.replace("\r", "").replace("\t", " ")
    s = re.sub(r"[  ]+", " ", s)
    s = re.sub(r" *\n *", "\n", s)
    return s.strip()


def fix_title(s, table):
    s = clean_text(s)
    for k, v in table.items():
        s = s.replace(k, v)
    return s


def load(name):
    with io.open(os.path.join(SRC, name), encoding="utf-8-sig") as f:
        return json.load(f, strict=False)


def extract_refs(footnote):
    """Short collection labels for UI chips, derived from the footnote.

    Names after "انظر" (secondary grading works such as "صحيح الترمذي") and
    names excluded with "إلا" are not treated as primary sources.
    """
    primary = re.split(r"و?ا?نظر", footnote)[0]
    found = []
    for pattern, ar, en in COLLECTIONS:
        for m in re.finditer(pattern, primary):
            if not re.search(r"إلا\s*$", primary[: m.start()]):
                found.append((m.start(), ar, en))
                break
    refs = [{"ar": ar, "en": en} for _, ar, en in sorted(found)]
    m = re.search(r"سورة\s+(آل عمران|[\u0621-\u064A]+)", footnote)
    if m:
        refs.insert(0, {"ar": "سورة " + m.group(1), "en": "Quran"})
    return refs


def stated_counts(text):
    """Counts the book states for the *whole* item.

    Only a trailing instruction after the quoted dhikr counts, e.g.
    "...العظيم)) (سبع مرات)." Counts inside the dhikr ("أستغفر الله (ثلاثاً)
    اللهم أنت السلام...") or inside a narrated hadith ("أتوب في اليوم إليه
    مائة مرة") apply to a phrase or describe a practice, so they are ignored.
    """
    m = re.search(r"[\)\]»]\s*[\(\[]([^()\[\]]+)[\)\]]\s*\.?\s*$", text)
    if not m:
        return set()
    n = norm(m.group(1))
    return {value for pattern, value in COUNT_WORDS if re.search(norm_pattern(pattern), n)}


def norm_pattern(p):
    # Patterns are written with hamza/diacritics; match them on normalised text.
    p = ARABIC_DIACRITICS.sub("", p)
    return re.sub("[أإآ]", "ا", p).replace("ة", "ه").replace("ئ", "ي")


def quran_share(text):
    quranic = sum(len(m) for m in re.findall(r"﴿[^﴾]*﴾", text))
    letters = len(re.sub(r"\s", "", text)) or 1
    return quranic / letters


EVENING_NOTE = re.compile(r"\[\s*و?إذا أمسى[^\]]*\]")


# --------------------------------------------------------------------------
# Footnote alignment (rn0x transcription -> official items)
# --------------------------------------------------------------------------
def align_footnotes(official_chapters, rn0x, report):
    """Returns {official_item_id: (footnote, confidence)}."""
    result = {}
    rn_titles = {norm(k): k for k in rn0x}
    for ch in official_chapters:
        if ch["id"] in TRANSCRIPTION_OVERRIDES:
            continue
        if ch["id"] in FOOTNOTE_TITLE_MAP:
            entry = rn0x[FOOTNOTE_TITLE_MAP[ch["id"]]]
        else:
            t = norm(ch["title"])
            best = max(rn_titles, key=lambda k: sim(t, k))
            if sim(t, best) < 0.75:
                report["footnote_chapters_unmatched"].append(ch["title"])
                continue
            entry = rn0x[rn_titles[best]]
        texts, notes = entry["text"], entry["footnote"]
        if ch["id"] in MANUAL_ALIGNMENT:
            pairs = [
                (texts[t], "\n".join(notes[i].strip() for i in fns))
                for t, fns in MANUAL_ALIGNMENT[ch["id"]].items()
            ]
            conf = "high"
        elif len(texts) == len(notes):
            pairs, conf = list(zip(texts, notes)), "high"
        else:
            sourced = [f for f in notes if SOURCE_HINT.search(f)]
            if len(sourced) == len(texts):
                pairs, conf = list(zip(texts, sourced)), "medium"
            else:
                report["footnote_chapters_ambiguous"].append(
                    f"{ch['id']} {ch['title']} (texts={len(texts)}, footnotes={len(notes)}, sourced={len(sourced)})"
                )
                continue
        official = [(it["ID"], norm(EVENING_NOTE.sub("", it["ARABIC_TEXT"]))) for it in ch["items"]]
        for rn_text, footnote in pairs:
            n = norm(rn_text)
            if not n:
                continue
            scored = sorted(((max(sim(n, o), coverage(n, o)), oid) for oid, o in official), reverse=True)
            score, oid = scored[0]
            if score < 0.6:
                continue
            footnote = clean_text(footnote)
            if oid in result:
                prev, prev_conf = result[oid]
                result[oid] = (prev + "\n" + footnote, min(prev_conf, conf))
            else:
                result[oid] = (footnote, conf)
    return result


# --------------------------------------------------------------------------
def build():
    ar = load("hisnmuslim_ar.json")
    en = load("hisnmuslim_en.json")
    rn0x = load("rn0x_hisn_almuslim.json")
    azkar_db = load("osamayy_azkar_db.json")
    quran = load("quran_duas_tanzil.json")

    chapters = {c["id"]: c for c in ar["chapters"]}
    en_chapters = {c["id"]: c for c in en["chapters"]}
    en_items = {it["ID"]: it for c in en["chapters"] for it in c["items"]}

    covered = Counter(cid for cat in CATEGORIES for cid in cat["chapters"] if cat["id"] != "evening")
    missing = set(chapters) - set(covered)
    dupes = [c for c, n in covered.items() if n > 1]
    assert not missing, f"chapters not mapped: {sorted(missing)}"
    assert not dupes, f"chapters mapped twice: {dupes}"

    report = {
        "footnote_chapters_unmatched": [],
        "footnote_chapters_ambiguous": [],
        "repeat_from_text": [],
        "repeat_ambiguous": [],
        "evening_from_dataset": [],
        "evening_fallback": [],
        "no_footnote": [],
        "no_translation": [],
        "text_from_transcription": [],
    }
    footnotes = align_footnotes(list(chapters.values()), rn0x, report)

    evening_rows = [r for r in azkar_db["rows"] if r[0] == "أذكار المساء"]

    categories_out, items_out = [], []

    for order, cat in enumerate(CATEGORIES):
        categories_out.append(
            OrderedDict(
                id=cat["id"], order=order, icon=cat["icon"],
                titleAr=cat["ar"], titleEn=cat["en"],
                subtitleAr=cat["sub_ar"], subtitleEn=cat["sub_en"],
            )
        )
        if cat.get("source") == "tanzil":
            for i, p in enumerate(quran["passages"]):
                text_parts, en_parts = [], []
                for a in p["ayahs"]:
                    text_parts.append(a["ar"].replace("\uFEFF", "").strip() + " " + arabic_number_marker(a["number"]))
                    en_parts.append(a["en"].strip())
                ayah_range = f"{p['from']}" if p["from"] == p["to"] else f"{p['from']}–{p['to']}"
                surah_ar = p["surahNameAr"].replace("س\u064Fور\u064Eة\u064F", "").strip()
                items_out.append(
                    OrderedDict(
                        id=f"q{p['surah']}-{p['from']}",
                        categoryId=cat["id"],
                        order=i,
                        sectionAr=f"سورة {surah_ar}",
                        sectionEn=f"Surah {p['surahNameEn']}",
                        text="﴿" + " ".join(text_parts) + "﴾",
                        repeat=1,
                        kind="quran",
                        footnote="",
                        refs=[{"ar": f"سورة {surah_ar} {to_arabic_digits(ayah_range)}",
                               "en": f"Quran {p['surah']}:{ayah_range}"}],
                        translation=" ".join(en_parts),
                        translationSource="Saheeh International",
                        transliteration="",
                        quranRef={"surah": p["surah"], "from": p["from"], "to": p["to"]},
                        source="tanzil:quran-simple",
                        flags=[],
                    )
                )
            continue

        idx = 0
        for cid in cat["chapters"]:
            ch = chapters[cid]
            sec_ar = fix_title(ch["title"], TITLE_FIXES_AR)
            sec_en = fix_title(en_chapters.get(cid, {}).get("title", ""), TITLE_FIXES_EN)
            if cid in TRANSCRIPTION_OVERRIDES:
                entry = rn0x[TRANSCRIPTION_OVERRIDES[cid]]
                for n, (t, fn) in enumerate(zip(entry["text"], entry["footnote"])):
                    fn = clean_text(fn)
                    report["text_from_transcription"].append(f"hm{cid}-{n + 1} ({sec_ar})")
                    items_out.append(
                        OrderedDict(
                            id=f"hm{cid}-{n + 1}", categoryId=cat["id"], order=idx,
                            sectionAr=sec_ar, sectionEn=sec_en, text=clean_text(t), note="",
                            repeat=1, kind="sunnah", footnote=fn, refs=extract_refs(fn),
                            translation="", translationSource="", transliteration="",
                            source=f"rn0x:{TRANSCRIPTION_OVERRIDES[cid]}",
                            flags=["text_from_transcription"],
                        )
                    )
                    idx += 1
                continue
            for it in ch["items"]:
                oid = it["ID"]
                raw = clean_text(it["ARABIC_TEXT"])
                flags = []
                note = ""
                text = raw
                variant = cat.get("variant")
                if variant:
                    notes = EVENING_NOTE.findall(raw)
                    morning_text = clean_text(EVENING_NOTE.sub("", raw))
                    body = norm(morning_text)
                    only_morning = "اذا اصبح" in body
                    only_evening = "اذا امسي" in body
                    if variant == "am":
                        if only_evening:
                            continue
                        text = morning_text
                    else:
                        if only_morning:
                            continue
                        text = morning_text
                        if notes:
                            note = " ".join(clean_text(n.strip("[] ")) for n in notes)
                            text, ok = evening_text(morning_text, notes, evening_rows)
                            if ok:
                                flags.append("evening_text_from_dataset")
                                report["evening_from_dataset"].append(oid)
                            else:
                                flags.append("evening_wording_in_note")
                                report["evening_fallback"].append(oid)

                repeat = max(1, int(it.get("REPEAT") or 1))
                counts = stated_counts(text)
                if len(counts) == 1:
                    stated = counts.pop()
                    if stated != repeat:
                        report["repeat_from_text"].append(f"{oid}: REPEAT={repeat} text says {stated}")
                        flags.append("repeat_from_text")
                        repeat = stated
                elif len(counts) > 1:
                    report["repeat_ambiguous"].append(f"{oid}: REPEAT={repeat} text mentions {sorted(counts)}")
                    flags.append("repeat_review")

                fn, conf = footnotes.get(oid, ("", None))
                if not fn:
                    flags.append("no_footnote")
                    report["no_footnote"].append(f"{oid} ({sec_ar})")
                elif conf == "medium":
                    flags.append("footnote_alignment_medium")

                en_it = en_items.get(oid, {})
                translation = clean_text(en_it.get("TRANSLATED_TEXT") or "")
                translit = clean_text(en_it.get("LANGUAGE_ARABIC_TRANSLATED_TEXT") or "")
                if not translation:
                    report["no_translation"].append(oid)

                suffix = {"am": ".am", "pm": ".pm"}.get(variant, "")
                items_out.append(
                    OrderedDict(
                        id=f"hm{oid}{suffix}",
                        categoryId=cat["id"],
                        order=idx,
                        sectionAr=sec_ar,
                        sectionEn=sec_en,
                        text=text,
                        note=note,
                        repeat=repeat,
                        kind="quran" if quran_share(text) >= 0.6 else "sunnah",
                        footnote=fn,
                        refs=extract_refs(fn),
                        translation=translation,
                        translationSource="hisnmuslim.com" if translation else "",
                        transliteration=translit,
                        source=f"hisnmuslim:{oid}",
                        flags=flags,
                    )
                )
                idx += 1

    for item in items_out:
        item.setdefault("note", "")
    ids = [i["id"] for i in items_out]
    assert len(ids) == len(set(ids)), "duplicate item ids"

    out = OrderedDict(
        version=CONTENT_VERSION,
        sources=[
            {"id": "hisnmuslim", "name": "Hisn al-Muslim — Sa'id ibn Ali ibn Wahf al-Qahtani",
             "url": "https://www.hisnmuslim.com/api/ar/husn_ar.json"},
            {"id": "rn0x", "name": "Book footnotes transcription (rn0x/hisn_almuslim_json)",
             "url": "https://github.com/rn0x/hisn_almuslim_json"},
            {"id": "azkar_db", "name": "Evening wording (osamayy/azkar-db)",
             "url": "https://github.com/osamayy/azkar-db"},
            {"id": "tanzil", "name": "Tanzil Quran text (quran-simple) via alquran.cloud",
             "url": "https://tanzil.net"},
        ],
        categories=categories_out,
        items=items_out,
    )
    os.makedirs(os.path.dirname(OUT_JSON), exist_ok=True)
    with io.open(OUT_JSON, "w", encoding="utf-8") as f:
        json.dump(out, f, ensure_ascii=False, separators=(",", ":"))
    write_report(out, report)
    per_cat = Counter(i["categoryId"] for i in items_out)
    print("items:", len(items_out), dict(per_cat))
    print({k: len(v) for k, v in report.items()})


def evening_text(morning_text, notes, evening_rows):
    """Pick the dataset's evening wording only if it contains every note."""
    phrases = []
    for n in notes:
        body = n.strip("[] ")
        body = re.sub(r"^و?إذا أمسى قال\s*:?", "", body)
        body = norm(body.replace("...", " ").replace("…", " "))
        if body:
            phrases.append(body)
    target = norm(morning_text)
    best, best_score = None, 0.0
    for row in evening_rows:
        score = sim(target, norm(row[1]))
        if score > best_score:
            best, best_score = row, score
    if best is not None and best_score >= 0.75:
        candidate = norm(best[1])
        if all(p in candidate for p in phrases):
            return clean_text(best[1]), True
    return morning_text, False


def to_arabic_digits(s):
    return s.translate(str.maketrans("0123456789", "٠١٢٣٤٥٦٧٨٩"))


def arabic_number_marker(n):
    return "(" + to_arabic_digits(str(n)) + ")"


def write_report(out, report):
    lines = [
        "# Content Verification Report",
        "",
        "_Generated by `tool/content/build_content.py` — do not edit by hand._",
        "",
        f"- Content version: **{out['version']}**",
        f"- Categories: **{len(out['categories'])}**",
        f"- Items: **{len(out['items'])}**",
        "",
        "> **Religious review status:** this content has been assembled automatically from the",
        "> sources below and cross-checked programmatically. It has **not** been reviewed by a",
        "> qualified scholar. Items listed here need human verification before they are",
        "> considered final.",
        "",
        "## Sources",
        "",
    ]
    for s in out["sources"]:
        lines.append(f"- **{s['name']}** — {s['url']}")
    lines += ["", "## Items per category", ""]
    per_cat = Counter(i["categoryId"] for i in out["items"])
    for c in out["categories"]:
        lines.append(f"- {c['titleAr']} / {c['titleEn']}: {per_cat[c['id']]}")

    def section(title, explanation, rows):
        lines.extend(["", f"## {title} ({len(rows)})", "", explanation, ""])
        lines.extend(f"- {r}" for r in rows) if rows else lines.append("- None")

    section("Repeat count taken from the book's wording", "The API `REPEAT` value disagreed with the count stated in the text itself; the stated count is used.", report["repeat_from_text"])
    section("Repeat count needs review", "The text mentions several different counts (usually composite adhkar). The API value is used.", report["repeat_ambiguous"])
    section("Evening wording taken from azkar-db", "The dataset's evening text contained every evening note from the book.", [str(x) for x in report["evening_from_dataset"]])
    section("Evening wording kept as the book's note", "No dataset text matched every note; the morning text is shown with the book's evening note.", [str(x) for x in report["evening_fallback"]])
    section("Footnote chapters not aligned (ambiguous)", "Footnote count did not match the text count; footnotes were not attached.", report["footnote_chapters_ambiguous"])
    section("Footnote chapters not found", "No matching chapter in the footnote transcription.", report["footnote_chapters_unmatched"])
    section("Items without a footnote/reference", "These items show 'reference not yet attached' in the app.", report["no_footnote"])
    section("Items without English translation", "", [str(x) for x in report["no_translation"]])
    section("Text taken from the book transcription", "The official API data for these chapters is defective (see `TRANSCRIPTION_OVERRIDES`).", report["text_from_transcription"])
    lines += ["", "## Heading typo fixes applied", ""]
    lines += [f"- `{k}` → `{v}`" for k, v in {**TITLE_FIXES_AR, **TITLE_FIXES_EN}.items()]
    os.makedirs(os.path.dirname(OUT_REPORT), exist_ok=True)
    with io.open(OUT_REPORT, "w", encoding="utf-8") as f:
        f.write("\n".join(lines) + "\n")


if __name__ == "__main__":
    build()
