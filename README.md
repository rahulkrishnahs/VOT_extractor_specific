# Praat Script: Extract Label Tier Durations with Phoneme Context

## Author

**Rahul Krishna H S** — https://github.com/rahulkrishnahs

---

## Overview

This Praat script extracts segment durations (in milliseconds) from the `label`
tier of TextGrid files, cross-referenced against the `phoneme` tier. It outputs
a structured CSV file enriched with metadata derived from the filename and label
annotations.

---

## Requirements

- Praat (version 6.0 or later): https://www.fon.hum.uva.nl/praat/
- TextGrid files with exactly two interval tiers named:
  - `label`   — contains word/token annotations (e.g. 21a, 33b)
  - `phoneme` — contains phoneme annotations (`t` or `d`)
- Audio files are not directly required by the script but should be co-located
  with the TextGrid files as part of the dataset.

---

## Setup

1. Open Praat.
2. Go to Praat > Open Praat script... and select `extract_durations.praat`.
3. Edit the two path variables at the top of the script:

   input_dir$   — full path to the folder containing your .TextGrid files
   output_file$ — full path and filename for the output CSV

   Example (Windows):
     input_dir$   = "C:/Users/user/Downloads/dataset/new/"
     output_file$ = "C:/Users/user/Downloads/durations.csv"

   IMPORTANT: Always use forward slashes "/" in paths, even on Windows.
              Always end the input_dir$ path with a "/".

4. Run the script: Run > Run

---

## Output

The script produces a CSV file with the following columns:

| Column              | Description                                                  |
|---------------------|--------------------------------------------------------------|
| filename            | Name of the source TextGrid file (without extension)         |
| label_interval      | Index of the interval in the label tier                      |
| label_text          | Annotation text of the label interval                        |
| start_s             | Start time of the interval in seconds                        |
| end_s               | End time of the interval in seconds                          |
| duration_ms         | Duration of the interval in milliseconds (always positive)   |
| phoneme_context     | Phoneme label (`t` or `d`) overlapping the label interval    |
| signed_duration_ms  | Duration * (-1) if phoneme is `d`, positive if `t`           |
| place               | Recording location: `TVM` or `KLM` (derived from filename)  |
| speaker_id          | Numeric speaker ID (TVM: 1–10, KLM: 11–20)                  |
| following_vowel     | Vowel context derived from numeral in label_text (see below) |
| repetition          | Repetition number derived from letter suffix in label_text   |

---

## Annotation Conventions

### Label Text Format
Each label annotation is expected to follow the format: [number][letter]
Examples: 21a, 33b, 27c

### Following Vowel Mapping
| Numerals          | following_vowel |
|-------------------|-----------------|
| 21, 22, 31, 32    | aa              |
| 23, 24, 33, 34    | ii              |
| 25, 26, 35, 36    | uu              |
| 27, 28, 37, 38    | ee              |
| 29, 30, 39, 40    | oo              |

### Repetition Mapping
| Letter suffix | repetition |
|---------------|------------|
| a             | 1          |
| b             | 2          |
| c             | 3          |

### Place and Speaker ID
- Filenames containing `TVM` → place = TVM, speaker_id counts from 1
- Filenames containing `KLM` → place = KLM, speaker_id counts from 11

---

## Skipping Rules

The script will skip an interval and not write a row if:
- The label tier annotation is empty or contains only whitespace
- The phoneme tier annotation at the midpoint is empty or contains only whitespace
- The interval duration is zero

A WARNING message will be printed to the Praat Info window if a file is missing
the `label` or `phoneme` tier entirely.

---

## Troubleshooting

| Problem                          | Solution                                                        |
|----------------------------------|-----------------------------------------------------------------|
| "folder does not exist" error    | Check path uses "/" not "\", and folder path ends with "/"      |
| "No permission to append" error  | Close the CSV in Excel before running the script                |
| File not found after running     | Verify your Windows username matches the path in the script     |
| Columns are shifted in CSV       | All text fields are quoted; ensure CSV viewer handles quotes    |
| speaker_id is 0                  | Filename does not contain "TVM" or "KLM"                        |
| following_vowel shows "unknown"  | Numeral in label does not match any defined range (21–40)       |

---

## License

This script is released under the MIT License. See LICENSE.txt for details.
