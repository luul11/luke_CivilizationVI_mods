-- SPAWN3
-- Author: james_pham
-- DateCreated: 24-Oct-24 11:21:15 PM
--------------------------------------------------------------
-- Update Barbarian Spawn Rate for Naval Tribes
UPDATE BarbarianTribes SET TurnsToWarriorSpawn = 6 WHERE TribeType = 'TRIBE_NAVAL';   -- Level 3

-- Update Barbarian Spawn Rate for Cavalry Tribes
UPDATE BarbarianTribes SET TurnsToWarriorSpawn = 15 WHERE TribeType = 'TRIBE_CAVALRY'; -- Level 3

-- Update Barbarian Spawn Rate for Melee Tribes
UPDATE BarbarianTribes SET TurnsToWarriorSpawn = 9 WHERE TribeType = 'TRIBE_MELEE';   -- Level 3

-- Barbarian Clan
UPDATE BarbarianTribes SET TurnsToWarriorSpawn = 6 WHERE TribeType = 'TRIBE_CLAN_MELEE_OPEN'; -- 6
UPDATE BarbarianTribes SET TurnsToWarriorSpawn = 9 WHERE TribeType = 'TRIBE_CLAN_MELEE_FOREST'; -- 9
UPDATE BarbarianTribes SET TurnsToWarriorSpawn = 9 WHERE TribeType = 'TRIBE_CLAN_MELEE_HILLS'; -- 9
UPDATE BarbarianTribes SET TurnsToWarriorSpawn = 12 WHERE TribeType = 'TRIBE_CLAN_CAVALRY_OPEN'; -- 12
UPDATE BarbarianTribes SET TurnsToWarriorSpawn = 12 WHERE TribeType = 'TRIBE_CLAN_CAVALRY_JUNGLE'; -- 12
UPDATE BarbarianTribes SET TurnsToWarriorSpawn = 12 WHERE TribeType = 'TRIBE_CLAN_CAVALRY_CHARIOT'; -- 12
UPDATE BarbarianTribes SET TurnsToWarriorSpawn = 9 WHERE TribeType = 'TRIBE_CLAN_NAVAL'; -- 9