# Release Notes — extract_durations.praat

**Author:** rahulkrishnahs — https://github.com/rahulkrishnahs

---

## Version 1.0.0 — March 2026

Initial release.

### Features

- Extracts segment durations in milliseconds from the `label` tier of TextGrid files
- Processes all `.TextGrid` files in a specified folder in batch
- Cross-references each label interval against the `phoneme` tier using the
  interval midpoint to determine phoneme context (`t` or `d`)
- Applies sign rule: duration is multiplied by -1 when phoneme context is `d`
- Skips unannotated or whitespace-only intervals in both `label` and `phoneme` tiers
- Derives `place` (TVM / KLM) from filename
- Assigns `speaker_id` automatically: TVM speakers numbered 1–10, KLM 11–20
- Derives `following_vowel` from numeric part of label annotation:
    21/22/31/32 → aa | 23/24/33/34 → ii | 25/26/35/36 → uu
    27/28/37/38 → ee | 29/30/39/40 → oo
- Derives `repetition` from letter suffix of label annotation:
    a → 1 | b → 2 | c → 3
- Quotes all text fields in CSV output to prevent column shift from
  special characters or spaces in annotations
- Prints WARNING to Praat Info window for files missing required tiers
- Prints confirmation message on successful completion

### Output Columns
filename, label_interval, label_text, start_s, end_s, duration_ms,
phoneme_context, signed_duration_ms, place, speaker_id, following_vowel, repetition

### Known Limitations

- Speaker ID assignment is based on file processing order (alphabetical).
  Ensure filenames sort correctly to get expected speaker numbering.
- The phoneme context is determined using the midpoint of the label interval.
  Label intervals that span across a `t`/`d` boundary will be assigned
  the phoneme at their midpoint only.
- Output folder must already exist before running — the script does not
  create new directories.
- The script does not support point tiers; both `label` and `phoneme` must
  be interval tiers.

---

## Planned / Possible Future Updates

- Support for additional phoneme categories beyond `t` and `d`
- Option to export one CSV per file instead of a single combined CSV
- GUI form for path entry within Praat
- Support for point tiers
