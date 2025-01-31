-- CON5
-- Author: james_pham
-- DateCreated: 06-Nov-24 11:50:04 AM
--------------------------------------------------------------
UPDATE TypeProperties SET Value = -5 WHERE Name = 'RAID_CONVERSION_POINTS_CHANGE';
UPDATE TypeProperties SET Value = 10 WHERE Name = 'HIRE_CONVERSION_POINTS_CHANGE';
UPDATE TypeProperties SET Value = 16 WHERE Name = 'BRIBE_CONVERSION_POINTS_CHANGE';

UPDATE GlobalParameters SET Value = 60 WHERE Name = 'BARBARIAN_CLANS_CIV_CONVERSION_POINTS_STANDARD';
