#!/usr/bin/env python3
"""Add audio_id column to all INSERT statements in seed.sql."""

import re

SEED_SQL = 'assets/quizzes/seed.sql'

# Map position -> existing fallback audio_id
FALLBACK_MAP = {
    1: 'fb-1', 4: 'fb-2', 5: 'fb-10', 15: 'fb-3', 17: 'fb-14',
    18: 'fb-11', 24: 'fb-4', 26: 'fb-5', 27: 'fb-12', 34: 'fb-6',
    35: 'fb-7', 44: 'fb-8', 46: 'fb-9', 36: 'fb-13', 45: 'fb-15',
    51: 'fb-16', 56: 'fb-17', 59: 'fb-18', 62: 'fb-19', 69: 'fb-20',
    84: 'fb-21', 85: 'fb-22', 87: 'fb-23', 90: 'fb-24', 91: 'fb-25',
    71: 'fb-ap-1', 79: 'fb-ap-2', 81: 'fb-ap-3', 76: 'fb-ap-4', 72: 'fb-ap-5',
}

with open(SEED_SQL, 'r') as f:
    content = f.read()

# 1. Update column list in INSERT statements
content = content.replace(
    'INSERT INTO quiz_questions (quiz_id, position, domain, scenario, prompt, options, correct_index, explanation)',
    'INSERT INTO quiz_questions (quiz_id, position, domain, scenario, prompt, options, correct_index, explanation, audio_id)'
)

# 2. For each VALUES block, add audio_id before the closing );
# Find all position numbers and add the correct audio_id
def add_audio_id(match):
    full = match.group(0)
    # Extract position number
    pos_match = re.search(r"'cca-daily-pool'\),\s*(\d+),", full)
    if not pos_match:
        return full
    position = int(pos_match.group(1))

    if position in FALLBACK_MAP:
        audio_id = f"'{FALLBACK_MAP[position]}'"
    else:
        audio_id = f"'db-{position}'"

    # Replace the closing ); with , audio_id);
    # Find the last explanation string's closing quote and the );
    # The pattern is: ...explanation text'\n);
    full = re.sub(r"'\s*\);$", f"',\n  {audio_id}\n);", full, flags=re.MULTILINE)
    return full

# Match each complete INSERT...); block
pattern = re.compile(
    r"INSERT INTO quiz_questions.*?VALUES\s*\(.*?\);",
    re.DOTALL
)

content = pattern.sub(add_audio_id, content)

with open(SEED_SQL, 'w') as f:
    f.write(content)

print("Done! Updated seed.sql with audio_id for all 91 questions.")
