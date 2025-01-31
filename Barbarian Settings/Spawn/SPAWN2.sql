-- SPAWN2
-- Author: james_pham
-- DateCreated: 24-Oct-24 11:21:10 PM
--------------------------------------------------------------
-- Update Barbarian Spawn Rate for Naval Tribes
UPDATE BarbarianTribes SET TurnsToWarriorSpawn = 8 WHERE TribeType = 'TRIBE_NAVAL';   -- Level 2

-- Update Barbarian Spawn Rate for Cavalry Tribes
UPDATE BarbarianTribes SET TurnsToWarriorSpawn = 20 WHERE TribeType = 'TRIBE_CAVALRY'; -- Level 2

-- Update Barbarian Spawn Rate for Melee Tribes
UPDATE BarbarianTribes SET TurnsToWarriorSpawn = 12 WHERE TribeType = 'TRIBE_MELEE';  -- Level 2

-- Barbarian Clan
UPDATE BarbarianTribes SET TurnsToWarriorSpawn = 8 WHERE TribeType = 'TRIBE_CLAN_MELEE_OPEN'; -- 8
UPDATE BarbarianTribes SET TurnsToWarriorSpawn = 12 WHERE TribeType = 'TRIBE_CLAN_MELEE_FOREST'; -- 12
UPDATE BarbarianTribes SET TurnsToWarriorSpawn = 12 WHERE TribeType = 'TRIBE_CLAN_MELEE_HILLS'; -- 12
UPDATE BarbarianTribes SET TurnsToWarriorSpawn = 16 WHERE TribeType = 'TRIBE_CLAN_CAVALRY_OPEN'; -- 16
UPDATE BarbarianTribes SET TurnsToWarriorSpawn = 16 WHERE TribeType = 'TRIBE_CLAN_CAVALRY_JUNGLE'; -- 16
UPDATE BarbarianTribes SET TurnsToWarriorSpawn = 16 WHERE TribeType = 'TRIBE_CLAN_CAVALRY_CHARIOT'; -- 16
UPDATE BarbarianTribes SET TurnsToWarriorSpawn = 12 WHERE TribeType = 'TRIBE_CLAN_NAVAL'; -- 12