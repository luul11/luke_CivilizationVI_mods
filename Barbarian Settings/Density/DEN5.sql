-- DEN5
-- Author: james_pham
-- DateCreated: 24-Oct-24 11:14:01 PM
--------------------------------------------------------------
-- First Turn Percent of Target to Add
UPDATE GlobalParameters SET Value = 100 WHERE Name = 'BARBARIAN_CAMP_FIRST_TURN_PERCENT_OF_TARGET_TO_ADD'; -- Level 5

-- Max Per Major Civilization
UPDATE GlobalParameters SET Value = 50 WHERE Name = 'BARBARIAN_CAMP_MAX_PER_MAJOR_CIV'; -- Level 5

-- Minimum Distance to Another Camp
UPDATE GlobalParameters SET Value = 2 WHERE Name = 'BARBARIAN_CAMP_MINIMUM_DISTANCE_ANOTHER_CAMP';  -- Level 5

-- Minimum Distance to City
UPDATE GlobalParameters SET Value = 2 WHERE Name = 'BARBARIAN_CAMP_MINIMUM_DISTANCE_CITY';  -- Level 5

-- Odds of New Camp Spawning
UPDATE GlobalParameters SET Value = 33 WHERE Name = 'BARBARIAN_CAMP_ODDS_OF_NEW_CAMP_SPAWNING'; -- Level 5
