#!/usr/bin/env python3
"""
Generate ElevenLabs audio for quiz questions that don't have audio yet.

Existing audio: fb-1..fb-25, fb-ap-1..fb-ap-5 (30 questions, 90 files)
New audio needed: db-2, db-3, db-6..db-14, db-16, db-19..db-23, db-25,
                  db-28..db-33, db-37..db-43, db-47..db-50, db-51..db-55,
                  db-56..db-58, db-59..db-61, db-62..db-65, db-66..db-68,
                  db-70, db-72..db-78, db-79..db-80, db-81..db-82,
                  db-83..db-84, db-85..db-86, db-87..db-88, db-89..db-90
Uses position-based IDs: db-{position}
"""

import json
import os
import sys
import time
import re
import urllib.request
import urllib.error

API_KEY = os.environ.get("ELEVENLABS_API_KEY", "")
VOICE_ID = os.environ.get("ELEVENLABS_VOICE_ID", "XhNlP8uwiH6XZSFnH1yL")  # Elizabeth Audiobook
AUDIO_DIR = os.path.join(os.path.dirname(os.path.dirname(__file__)), "assets", "quizzes", "audio")
SEED_SQL = os.path.join(os.path.dirname(os.path.dirname(__file__)), "assets", "quizzes", "seed.sql")

# Positions that already have audio (mapped to fb-* IDs)
# Based on the earlier analysis mapping seed positions to fallback questions
EXISTING_AUDIO_POSITIONS = {
    1,   # fb-1
    4,   # fb-2
    5,   # fb-10
    15,  # fb-3
    17,  # fb-14
    18,  # fb-11
    24,  # fb-4
    26,  # fb-5
    27,  # fb-12
    34,  # fb-6
    35,  # fb-7
    44,  # fb-8
    46,  # fb-9
    36,  # fb-13
    45,  # fb-15
    51,  # fb-16
    56,  # fb-17
    59,  # fb-18
    62,  # fb-19
    69,  # fb-20
    84,  # fb-21
    85,  # fb-22
    87,  # fb-23
    90,  # fb-24
    91,  # fb-25
    71,  # fb-ap-1
    79,  # fb-ap-2
    81,  # fb-ap-3
    76,  # fb-ap-4
    72,  # fb-ap-5
}

LETTERS = ['A', 'B', 'C', 'D']


def parse_seed_sql(path):
    """Parse seed.sql to extract all questions with their position, scenario, prompt, options, correct_index, explanation."""
    with open(path, 'r') as f:
        content = f.read()

    # Strip block comment markers so we can parse commented-out questions too
    content = content.replace('/*', '').replace('*/', '')

    questions = []
    # Find all INSERT INTO quiz_questions blocks
    # Each block has: position, domain, scenario, prompt, options (jsonb), correct_index, explanation
    pattern = re.compile(
        r"INSERT INTO quiz_questions.*?VALUES\s*\(\s*"
        r"\(SELECT id FROM quizzes WHERE slug = 'cca-daily-pool'\),\s*"
        r"(\d+),\s*"  # position
        r"'([^']*)',\s*"  # domain
        r"'((?:[^']|'')*)',\s*"  # scenario (may contain escaped quotes)
        r"'((?:[^']|'')*)',\s*"  # prompt
        r"'((?:[^']|'')*)'::jsonb,\s*"  # options as JSON string
        r"(\d+),\s*"  # correct_index
        r"'((?:[^']|'')*)'"  # explanation
        r"(?:,\s*'[^']*')?"  # optional audio_id
        r"\s*\)",
        re.DOTALL
    )

    for match in pattern.finditer(content):
        position = int(match.group(1))
        domain = match.group(2)
        scenario = match.group(3).replace("''", "'")
        prompt = match.group(4).replace("''", "'")
        options_json = match.group(5).replace("''", "'")
        correct_index = int(match.group(6))
        explanation = match.group(7).replace("''", "'")

        try:
            options = json.loads(options_json)
        except json.JSONDecodeError:
            print(f"  WARNING: Could not parse options for position {position}, skipping")
            continue

        questions.append({
            'position': position,
            'domain': domain,
            'scenario': scenario,
            'prompt': prompt,
            'options': options,
            'correct_index': correct_index,
            'explanation': explanation,
        })

    return questions


def build_question_text(q):
    """Build the text for reading a question aloud."""
    text = q['scenario'] + ' ' + q['prompt'] + ' '
    for i, opt in enumerate(q['options']):
        text += f"Option {LETTERS[i]}: {opt}. "
    return text


def build_correct_text(q):
    """Build the text for correct answer explanation."""
    return f"Correct! {q['explanation']}"


def build_incorrect_text(q):
    """Build the text for incorrect answer explanation."""
    correct_letter = LETTERS[q['correct_index']]
    return f"Incorrect. The correct answer is {correct_letter}. {q['explanation']}"


def generate_audio(text, output_path):
    """Generate audio via ElevenLabs API."""
    url = f"https://api.elevenlabs.io/v1/text-to-speech/{VOICE_ID}"
    payload = json.dumps({
        "text": text,
        "model_id": "eleven_multilingual_v2",
        "voice_settings": {
            "stability": 0.5,
            "similarity_boost": 0.75,
            "style": 0.0,
            "use_speaker_boost": True
        }
    }).encode('utf-8')

    req = urllib.request.Request(url, data=payload, method='POST')
    req.add_header('xi-api-key', API_KEY)
    req.add_header('Content-Type', 'application/json')
    req.add_header('Accept', 'audio/mpeg')

    try:
        with urllib.request.urlopen(req, timeout=120) as resp:
            with open(output_path, 'wb') as f:
                f.write(resp.read())
        return True
    except urllib.error.HTTPError as e:
        body = e.read().decode('utf-8', errors='replace')
        print(f"  HTTP {e.code}: {body[:200]}")
        return False
    except (urllib.error.URLError, OSError) as e:
        print(f"  Error: {e}")
        return False


def main():
    if not API_KEY:
        print("Error: ELEVENLABS_API_KEY environment variable not set")
        sys.exit(1)

    print("Parsing seed.sql...")
    questions = parse_seed_sql(SEED_SQL)
    print(f"Found {len(questions)} questions")

    # Filter to only questions that need new audio
    new_questions = [q for q in questions if q['position'] not in EXISTING_AUDIO_POSITIONS]
    print(f"{len(new_questions)} questions need new audio ({len(new_questions) * 3} files)")

    os.makedirs(AUDIO_DIR, exist_ok=True)

    total = len(new_questions) * 3
    done = 0
    failed = 0

    for q in new_questions:
        audio_id = f"db-{q['position']}"
        files = [
            (f"{audio_id}.mp3", build_question_text(q)),
            (f"{audio_id}-correct.mp3", build_correct_text(q)),
            (f"{audio_id}-incorrect.mp3", build_incorrect_text(q)),
        ]

        for filename, text in files:
            output_path = os.path.join(AUDIO_DIR, filename)
            if os.path.exists(output_path) and os.path.getsize(output_path) > 1000:
                print(f"  SKIP (exists): {filename}")
                done += 1
                continue

            print(f"  [{done+1}/{total}] Generating {filename} ({len(text)} chars)...")
            ok = generate_audio(text, output_path)
            if ok:
                size = os.path.getsize(output_path)
                print(f"    OK ({size:,} bytes)")
            else:
                print(f"    FAILED")
                failed += 1
            done += 1
            # Rate limit: ElevenLabs allows ~2-3 req/sec on most plans
            time.sleep(0.5)

    print(f"\nDone! Generated {done - failed}/{total} files ({failed} failures)")


if __name__ == '__main__':
    main()
