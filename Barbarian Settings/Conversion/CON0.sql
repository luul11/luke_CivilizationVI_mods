-- CON0
-- Author: james_pham
-- DateCreated: 06-Nov-24 11:49:11 AM
--------------------------------------------------------------
UPDATE TypeProperties SET Value = -15 WHERE Name = 'RAID_CONVERSION_POINTS_CHANGE';
UPDATE TypeProperties SET Value = 4 WHERE Name = 'HIRE_CONVERSION_POINTS_CHANGE';
UPDATE TypeProperties SET Value = 6 WHERE Name = 'BRIBE_CONVERSION_POINTS_CHANGE';

UPDATE GlobalParameters SET Value = 180 WHERE Name = 'BARBARIAN_CLANS_CIV_CONVERSION_POINTS_STANDARD';
