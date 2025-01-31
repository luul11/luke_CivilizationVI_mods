-- ERA0
-- Author: james_pham
-- DateCreated: 14-Nov-24 9:06:41 PM
--------------------------------------------------------------
-- Barbarians can spawn Galleys and Quadquiremes at the beginning of the game.
UPDATE Technologies
SET BarbarianFree = 1
WHERE BarbarianFree = 0 AND TechnologyType IN ('TECH_SHIPBUILDING', 'TECH_SAILING');

-- Barbarians can spawn mounted units at the beginning of the game.
UPDATE Units
SET PrereqTech = NULL
WHERE UnitType IN ('UNIT_BARBARIAN_HORSE_ARCHER', 'UNIT_BARBARIAN_HORSEMAN');
