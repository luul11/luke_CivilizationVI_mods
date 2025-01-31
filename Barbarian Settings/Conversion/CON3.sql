-- CON3
-- Author: james_pham
-- DateCreated: 06-Nov-24 11:49:53 AM
--------------------------------------------------------------
UPDATE TypeProperties SET Value = -7 WHERE Name = 'RAID_CONVERSION_POINTS_CHANGE';
UPDATE TypeProperties SET Value = 7 WHERE Name = 'HIRE_CONVERSION_POINTS_CHANGE';
UPDATE TypeProperties SET Value = 12 WHERE Name = 'BRIBE_CONVERSION_POINTS_CHANGE';

UPDATE GlobalParameters SET Value = 90 WHERE Name = 'BARBARIAN_CLANS_CIV_CONVERSION_POINTS_STANDARD';

