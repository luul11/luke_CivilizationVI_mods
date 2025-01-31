-- SPAWN4
-- Author: james_pham
-- DateCreated: 24-Oct-24 11:21:19 PM
--------------------------------------------------------------
-- Update Barbarian Spawn Rate for Naval Tribes
UPDATE BarbarianTribes SET TurnsToWarriorSpawn = 4 WHERE TribeType = 'TRIBE_NAVAL';   -- Level 4

-- Update Barbarian Spawn Rate for Cavalry Tribes
UPDATE BarbarianTribes SET TurnsToWarriorSpawn = 10 WHERE TribeType = 'TRIBE_CAVALRY'; -- Level 4

-- Update Barbarian Spawn Rate for Melee Tribes
UPDATE BarbarianTribes SET TurnsToWarriorSpawn = 6 WHERE TribeType = 'TRIBE_MELEE';   -- Level 4

-- Barbarian Clan
UPDATE BarbarianTribes SET TurnsToWarriorSpawn = 4 WHERE TribeType = 'TRIBE_CLAN_MELEE_OPEN'; -- 4
UPDATE BarbarianTribes SET TurnsToWarriorSpawn = 6 WHERE TribeType = 'TRIBE_CLAN_MELEE_FOREST'; -- 6
UPDATE BarbarianTribes SET TurnsToWarriorSpawn = 6 WHERE TribeType = 'TRIBE_CLAN_MELEE_HILLS'; -- 6
UPDATE BarbarianTribes SET TurnsToWarriorSpawn = 8 WHERE TribeType = 'TRIBE_CLAN_CAVALRY_OPEN'; -- 8
UPDATE BarbarianTribes SET TurnsToWarriorSpawn = 8 WHERE TribeType = 'TRIBE_CLAN_CAVALRY_JUNGLE'; -- 8
UPDATE BarbarianTribes SET TurnsToWarriorSpawn = 8 WHERE TribeType = 'TRIBE_CLAN_CAVALRY_CHARIOT'; -- 8
UPDATE BarbarianTribes SET TurnsToWarriorSpawn = 6 WHERE TribeType = 'TRIBE_CLAN_NAVAL'; -- 6