-- DEN3
-- Author: james_pham
-- DateCreated: 24-Oct-24 11:13:39 PM
--------------------------------------------------------------
-- First Turn Percent of Target to Add
UPDATE GlobalParameters SET Value = 66 WHERE Name = 'BARBARIAN_CAMP_FIRST_TURN_PERCENT_OF_TARGET_TO_ADD';  -- Level 3

-- Max Per Major Civilization
UPDATE GlobalParameters SET Value = 12 WHERE Name = 'BARBARIAN_CAMP_MAX_PER_MAJOR_CIV'; -- Level 3

-- Minimum Distance to Another Camp
UPDATE GlobalParameters SET Value = 4 WHERE Name = 'BARBARIAN_CAMP_MINIMUM_DISTANCE_ANOTHER_CAMP';  -- Level 3

-- Minimum Distance to City
UPDATE GlobalParameters SET Value = 3 WHERE Name = 'BARBARIAN_CAMP_MINIMUM_DISTANCE_CITY';  -- Level 3

-- Odds of New Camp Spawning
UPDATE GlobalParameters SET Value = 8 WHERE Name = 'BARBARIAN_CAMP_ODDS_OF_NEW_CAMP_SPAWNING';  -- Level 3
