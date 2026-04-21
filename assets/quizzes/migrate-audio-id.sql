-- ============================================================================
-- Migrate: Add audio_id column and populate for all 91 questions
-- Run this in the Supabase SQL editor
-- ============================================================================

-- Step 1: Add the column
ALTER TABLE quiz_questions ADD COLUMN IF NOT EXISTS audio_id text;

-- Step 2: Set audio_id for all questions by position
-- Original 30 questions map to fb-* IDs (matching existing audio files)
-- New 61 questions map to db-{position} IDs

UPDATE quiz_questions SET audio_id = CASE position
  -- Original fallback questions (fb-* audio files)
  WHEN 1  THEN 'fb-1'
  WHEN 4  THEN 'fb-2'
  WHEN 5  THEN 'fb-10'
  WHEN 15 THEN 'fb-3'
  WHEN 17 THEN 'fb-14'
  WHEN 18 THEN 'fb-11'
  WHEN 24 THEN 'fb-4'
  WHEN 26 THEN 'fb-5'
  WHEN 27 THEN 'fb-12'
  WHEN 34 THEN 'fb-6'
  WHEN 35 THEN 'fb-7'
  WHEN 36 THEN 'fb-13'
  WHEN 44 THEN 'fb-8'
  WHEN 45 THEN 'fb-15'
  WHEN 46 THEN 'fb-9'
  WHEN 51 THEN 'fb-16'
  WHEN 56 THEN 'fb-17'
  WHEN 59 THEN 'fb-18'
  WHEN 62 THEN 'fb-19'
  WHEN 69 THEN 'fb-20'
  WHEN 71 THEN 'fb-ap-1'
  WHEN 72 THEN 'fb-ap-5'
  WHEN 76 THEN 'fb-ap-4'
  WHEN 79 THEN 'fb-ap-2'
  WHEN 81 THEN 'fb-ap-3'
  WHEN 84 THEN 'fb-21'
  WHEN 85 THEN 'fb-22'
  WHEN 87 THEN 'fb-23'
  WHEN 90 THEN 'fb-24'
  WHEN 91 THEN 'fb-25'
  -- New questions (db-{position} audio files)
  ELSE 'db-' || position::text
END
WHERE quiz_id = (SELECT id FROM quizzes WHERE slug = 'cca-daily-pool');

-- Verify: should return 91 rows, all with non-null audio_id
SELECT position, audio_id FROM quiz_questions
WHERE quiz_id = (SELECT id FROM quizzes WHERE slug = 'cca-daily-pool')
ORDER BY position;
