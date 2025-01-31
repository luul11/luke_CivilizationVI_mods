-- CON1
-- Author: james_pham
-- DateCreated: 06-Nov-24 11:49:22 AM
--------------------------------------------------------------
UPDATE TypeProperties SET Value = -10 WHERE Name = 'RAID_CONVERSION_POINTS_CHANGE';
UPDATE TypeProperties SET Value = 5 WHERE Name = 'HIRE_CONVERSION_POINTS_CHANGE';
UPDATE TypeProperties SET Value = 8 WHERE Name = 'BRIBE_CONVERSION_POINTS_CHANGE';

UPDATE GlobalParameters SET Value = 120 WHERE Name = 'BARBARIAN_CLANS_CIV_CONVERSION_POINTS_STANDARD';
