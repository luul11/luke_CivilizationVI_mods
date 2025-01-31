-- SPAWN5
-- Author: james_pham
-- DateCreated: 24-Oct-24 11:21:24 PM
--------------------------------------------------------------
-- Update Barbarian Spawn Rate for Naval Tribes
UPDATE BarbarianTribes SET TurnsToWarriorSpawn = 2 WHERE TribeType = 'TRIBE_NAVAL';   -- Level 5

-- Update Barbarian Spawn Rate for Cavalry Tribes
UPDATE BarbarianTribes SET TurnsToWarriorSpawn = 5 WHERE TribeType = 'TRIBE_CAVALRY';  -- Level 5

-- Update Barbarian Spawn Rate for Melee Tribes
UPDATE BarbarianTribes SET TurnsToWarriorSpawn = 3 WHERE TribeType = 'TRIBE_MELEE';   -- Level 5

-- Barbarian Clan
UPDATE BarbarianTribes SET TurnsToWarriorSpawn = 2 WHERE TribeType = 'TRIBE_CLAN_MELEE_OPEN'; -- 2
UPDATE BarbarianTribes SET TurnsToWarriorSpawn = 3 WHERE TribeType = 'TRIBE_CLAN_MELEE_FOREST'; -- 3
UPDATE BarbarianTribes SET TurnsToWarriorSpawn = 3 WHERE TribeType = 'TRIBE_CLAN_MELEE_HILLS'; -- 3
UPDATE BarbarianTribes SET TurnsToWarriorSpawn = 5 WHERE TribeType = 'TRIBE_CLAN_CAVALRY_OPEN'; -- 5
UPDATE BarbarianTribes SET TurnsToWarriorSpawn = 5 WHERE TribeType = 'TRIBE_CLAN_CAVALRY_JUNGLE'; -- 5
UPDATE BarbarianTribes SET TurnsToWarriorSpawn = 5 WHERE TribeType = 'TRIBE_CLAN_CAVALRY_CHARIOT'; -- 5
UPDATE BarbarianTribes SET TurnsToWarriorSpawn = 3 WHERE TribeType = 'TRIBE_CLAN_NAVAL'; -- 3