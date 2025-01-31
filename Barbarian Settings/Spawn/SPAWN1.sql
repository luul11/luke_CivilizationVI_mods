-- SPAWN1
-- Author: james_pham
-- DateCreated: 24-Oct-24 11:21:06 PM
--------------------------------------------------------------
-- Update Barbarian Spawn Rate for Naval Tribes
UPDATE BarbarianTribes SET TurnsToWarriorSpawn = 10 WHERE TribeType = 'TRIBE_NAVAL';  -- Level 1

-- Update Barbarian Spawn Rate for Cavalry Tribes
UPDATE BarbarianTribes SET TurnsToWarriorSpawn = 25 WHERE TribeType = 'TRIBE_CAVALRY'; -- Level 1

-- Update Barbarian Spawn Rate for Melee Tribes
UPDATE BarbarianTribes SET TurnsToWarriorSpawn = 15 WHERE TribeType = 'TRIBE_MELEE';  -- Level 1

-- Barbarian Clan
UPDATE BarbarianTribes SET TurnsToWarriorSpawn = 10 WHERE TribeType = 'TRIBE_CLAN_MELEE_OPEN'; -- 10
UPDATE BarbarianTribes SET TurnsToWarriorSpawn = 15 WHERE TribeType = 'TRIBE_CLAN_MELEE_FOREST'; -- 15
UPDATE BarbarianTribes SET TurnsToWarriorSpawn = 15 WHERE TribeType = 'TRIBE_CLAN_MELEE_HILLS'; -- 15
UPDATE BarbarianTribes SET TurnsToWarriorSpawn = 20 WHERE TribeType = 'TRIBE_CLAN_CAVALRY_OPEN'; -- 20
UPDATE BarbarianTribes SET TurnsToWarriorSpawn = 20 WHERE TribeType = 'TRIBE_CLAN_CAVALRY_JUNGLE'; -- 20
UPDATE BarbarianTribes SET TurnsToWarriorSpawn = 20 WHERE TribeType = 'TRIBE_CLAN_CAVALRY_CHARIOT'; -- 20
UPDATE BarbarianTribes SET TurnsToWarriorSpawn = 15 WHERE TribeType = 'TRIBE_CLAN_NAVAL'; -- 15