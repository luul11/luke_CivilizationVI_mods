-- ERA1
-- Author: james_pham
-- DateCreated: 14-Nov-24 9:06:47 PM
--------------------------------------------------------------
-- Remove free Shipbuilding tech. No longer spawn Quadquiremes at the beginning of the game.
UPDATE Technologies
SET BarbarianFree = 0
WHERE BarbarianFree = 1 AND TechnologyType IN ('TECH_SHIPBUILDING');

-- Barbarian Horse Archers require Archery tech to spawn.
UPDATE Units
SET PrereqTech = 'TECH_ARCHERY'
WHERE UnitType IN ('UNIT_BARBARIAN_HORSE_ARCHER');
