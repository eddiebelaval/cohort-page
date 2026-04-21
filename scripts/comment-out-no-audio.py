#!/usr/bin/env python3
"""Comment out seed.sql questions that don't have complete audio yet."""

import re

SEED_SQL = 'assets/quizzes/seed.sql'

# Positions to comment out (no audio or partial audio)
COMMENT_OUT = {43,47,48,49,50,52,53,54,55,57,58,60,61,63,64,65,66,67,68,70,73,74,75,77,78,80,82,83,86,88,89}

with open(SEED_SQL, 'r') as f:
    content = f.read()

def comment_block(match):
    full = match.group(0)
    pos_match = re.search(r"'cca-daily-pool'\),\s*(\d+),", full)
    if not pos_match:
        return full
    position = int(pos_match.group(1))
    if position in COMMENT_OUT:
        # Wrap in block comment with a note
        return f"-- [AWAITING AUDIO] Position {position} — uncomment after generating ElevenLabs audio\n/*\n{full}\n*/"
    return full

pattern = re.compile(
    r"INSERT INTO quiz_questions.*?VALUES\s*\(.*?\);",
    re.DOTALL
)

content = pattern.sub(comment_block, content)

# Update question count to 60
content = content.replace(
    "UPDATE quizzes SET question_count = 91 WHERE slug = 'cca-daily-pool';",
    "UPDATE quizzes SET question_count = 60 WHERE slug = 'cca-daily-pool';\n-- NOTE: 31 questions commented out awaiting ElevenLabs credits. Run scripts/generate-audio.py then scripts/comment-out-no-audio.py to uncomment."
)

with open(SEED_SQL, 'w') as f:
    f.write(content)

print(f"Commented out {len(COMMENT_OUT)} questions. Active count: {91 - len(COMMENT_OUT)}")
