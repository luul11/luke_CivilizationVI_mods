-- CON4
-- Author: james_pham
-- DateCreated: 06-Nov-24 11:49:58 AM
--------------------------------------------------------------
UPDATE TypeProperties SET Value = -6 WHERE Name = 'RAID_CONVERSION_POINTS_CHANGE';
UPDATE TypeProperties SET Value = 9 WHERE Name = 'HIRE_CONVERSION_POINTS_CHANGE';
UPDATE TypeProperties SET Value = 14 WHERE Name = 'BRIBE_CONVERSION_POINTS_CHANGE';

UPDATE GlobalParameters SET Value = 75 WHERE Name = 'BARBARIAN_CLANS_CIV_CONVERSION_POINTS_STANDARD';

