-- SPAWN0
-- Author: james_pham
-- DateCreated: 24-Oct-24 11:21:01 PM
--------------------------------------------------------------
-- Update Barbarian Spawn Rate for Naval Tribes
UPDATE BarbarianTribes SET TurnsToWarriorSpawn = 12 WHERE TribeType = 'TRIBE_NAVAL';  -- Level 0

-- Update Barbarian Spawn Rate for Cavalry Tribes
UPDATE BarbarianTribes SET TurnsToWarriorSpawn = 30 WHERE TribeType = 'TRIBE_CAVALRY'; -- Level 0

-- Update Barbarian Spawn Rate for Melee Tribes
UPDATE BarbarianTribes SET TurnsToWarriorSpawn = 18 WHERE TribeType = 'TRIBE_MELEE';  -- Level 0

-- Barbarian Clan
UPDATE BarbarianTribes SET TurnsToWarriorSpawn = 12 WHERE TribeType = 'TRIBE_CLAN_MELEE_OPEN'; -- 12
UPDATE BarbarianTribes SET TurnsToWarriorSpawn = 18 WHERE TribeType = 'TRIBE_CLAN_MELEE_FOREST'; -- 18
UPDATE BarbarianTribes SET TurnsToWarriorSpawn = 18 WHERE TribeType = 'TRIBE_CLAN_MELEE_HILLS'; -- 18
UPDATE BarbarianTribes SET TurnsToWarriorSpawn = 25 WHERE TribeType = 'TRIBE_CLAN_CAVALRY_OPEN'; -- 25
UPDATE BarbarianTribes SET TurnsToWarriorSpawn = 25 WHERE TribeType = 'TRIBE_CLAN_CAVALRY_JUNGLE'; -- 25
UPDATE BarbarianTribes SET TurnsToWarriorSpawn = 25 WHERE TribeType = 'TRIBE_CLAN_CAVALRY_CHARIOT'; -- 25
UPDATE BarbarianTribes SET TurnsToWarriorSpawn = 18 WHERE TribeType = 'TRIBE_CLAN_NAVAL'; -- 18