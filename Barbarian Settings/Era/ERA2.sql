-- ERA2
-- Author: james_pham
-- DateCreated: 14-Nov-24 9:49:26 PM
--------------------------------------------------------------

-- Remove free Shipbuilding and Sailing tech. No longer spawn Galleys and Quadquiremes at the beginning of the game
UPDATE Technologies
SET BarbarianFree = 0
WHERE BarbarianFree = 1 AND TechnologyType IN ('TECH_SHIPBUILDING', 'TECH_SAILING');

-- Barbarians require to have Horseback Riding tech to spawn mounted units.
UPDATE Units
SET PrereqTech = 'TECH_HORSEBACK_RIDING'
WHERE UnitType IN ('UNIT_BARBARIAN_HORSE_ARCHER', 'UNIT_BARBARIAN_HORSEMAN');
