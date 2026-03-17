# ============================================================
# Praat Script: Extract Label Tier Durations with Phoneme Context
    Made by Rahul Krishna H S
# ============================================================
# Rules:
#   - Extract durations (ms) from 'label' tier
#   - Duration * (-1) if phoneme context is 'd'
#   - Skip blank/unannotated label or phoneme intervals
#   - Add columns: place, repetition, speaker_id, following_vowel
#   - place: 'TVM' or 'KLM' based on filename
#   - speaker_id: TVM files count from 1, KLM files count from 11
#   - following_vowel: derived from numerals in label_text
#   - repetition: derived from letter suffix (a=1, b=2, c=3) in label_text
# ============================================================

# --- USER SETTINGS ---
input_dir$ = "C:/Users/user/Downloads/Newdataset-20260301T070620Z-1-001/new/"
output_file$ = "C:/Users/user/Downloads/durations.csv"

# --- SETUP OUTPUT FILE ---
writeFileLine: output_file$, "filename,label_interval,label_text,start_s,end_s,duration_ms,phoneme_context,signed_duration_ms,place,speaker_id,following_vowel,repetition"

# --- SPEAKER ID COUNTERS ---
tvm_count = 0
klm_count = 0

# --- PROCESS EACH TEXTGRID FILE ---
strings = Create Strings as file list: "fileList", input_dir$ + "*.TextGrid"
n_files = Get number of strings

for i_file from 1 to n_files
    selectObject: strings
    filename$ = Get string: i_file
    filepath$ = input_dir$ + filename$

    tg = Read from file: filepath$
    basename$ = filename$ - ".TextGrid"

    # --- DETERMINE PLACE AND SPEAKER ID ---
    if index (basename$, "TVM") > 0
        place$ = "TVM"
        tvm_count = tvm_count + 1
        speaker_id = tvm_count
    elsif index (basename$, "KLM") > 0
        place$ = "KLM"
        klm_count = klm_count + 1
        speaker_id = 10 + klm_count
    else
        place$ = "unknown"
        speaker_id = 0
    endif

    # --- GET TIER INDICES ---
    n_tiers = Get number of tiers
    label_tier = 0
    phoneme_tier = 0

    for t from 1 to n_tiers
        tier_name$ = Get tier name: t
        if tier_name$ = "label"
            label_tier = t
        endif
        if tier_name$ = "phoneme"
            phoneme_tier = t
        endif
    endfor

    # --- VALIDATE TIERS AND PROCESS ---
    if label_tier = 0
        appendInfoLine: "WARNING: No 'label' tier found in " + filename$
    elsif phoneme_tier = 0
        appendInfoLine: "WARNING: No 'phoneme' tier found in " + filename$
    else
        n_label_intervals = Get number of intervals: label_tier

        for i_label from 1 to n_label_intervals
            selectObject: tg

            label_text$ = Get label of interval: label_tier, i_label
            label_start = Get start point: label_tier, i_label
            label_end = Get end point: label_tier, i_label
            label_dur_s = label_end - label_start
            label_dur_ms = label_dur_s * 1000

            # Strip whitespace from label
            cleaned_label$ = replace_regex$ (label_text$, "^\s+|\s+$", "", 0)

            if cleaned_label$ <> "" and label_dur_s > 0

                # --- PHONEME CONTEXT ---
                label_mid = (label_start + label_end) / 2
                phoneme_interval = Get interval at time: phoneme_tier, label_mid
                phoneme_text$ = Get label of interval: phoneme_tier, phoneme_interval
                cleaned_phoneme$ = replace_regex$ (phoneme_text$, "^\s+|\s+$", "", 0)

                if cleaned_phoneme$ <> ""

                    # --- APPLY SIGN RULE ---
                    if cleaned_phoneme$ = "d"
                        signed_dur_ms = label_dur_ms * -1
                    else
                        signed_dur_ms = label_dur_ms
                    endif

                    # --- FOLLOWING VOWEL (based on numerals in label_text) ---
                    # Extract numeric part using regex (remove trailing letter a/b/c)
                    num_part$ = replace_regex$ (cleaned_label$, "[abc]$", "", 0)

                    if num_part$ = "21" or num_part$ = "22" or num_part$ = "31" or num_part$ = "32"
                        following_vowel$ = "aa"
                    elsif num_part$ = "23" or num_part$ = "24" or num_part$ = "33" or num_part$ = "34"
                        following_vowel$ = "ii"
                    elsif num_part$ = "25" or num_part$ = "26" or num_part$ = "35" or num_part$ = "36"
                        following_vowel$ = "uu"
                    elsif num_part$ = "27" or num_part$ = "28" or num_part$ = "37" or num_part$ = "38"
                        following_vowel$ = "ee"
                    elsif num_part$ = "29" or num_part$ = "30" or num_part$ = "39" or num_part$ = "40"
                        following_vowel$ = "oo"
                    else
                        following_vowel$ = "unknown"
                    endif

                    # --- REPETITION (based on trailing letter in label_text) ---
                    letter_part$ = replace_regex$ (cleaned_label$, "^[0-9]+", "", 0)

                    if letter_part$ = "a"
                        repetition$ = "1"
                    elsif letter_part$ = "b"
                        repetition$ = "2"
                    elsif letter_part$ = "c"
                        repetition$ = "3"
                    else
                        repetition$ = "unknown"
                    endif

                    # --- WRITE ROW TO CSV ---
                    appendFileLine: output_file$,
                        ... """" + basename$ + """" + "," +
                        ... string$(i_label) + "," +
                        ... """" + cleaned_label$ + """" + "," +
                        ... string$(label_start) + "," +
                        ... string$(label_end) + "," +
                        ... string$(label_dur_ms) + "," +
                        ... """" + cleaned_phoneme$ + """" + "," +
                        ... string$(signed_dur_ms) + "," +
                        ... """" + place$ + """" + "," +
                        ... string$(speaker_id) + "," +
                        ... """" + following_vowel$ + """" + "," +
                        ... """" + repetition$ + """"

                endif
            endif
        endfor

    endif

    removeObject: tg
endfor

removeObject: strings

appendInfoLine: "Done! Results saved to: " + output_file$
