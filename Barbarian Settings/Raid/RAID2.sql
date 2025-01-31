-- RAID2
-- Author: james_pham
-- DateCreated: 25-Oct-24 12:10:27 AM
--------------------------------------------------------------
-- Update Barbarian Raid Numbers for x2
UPDATE BarbarianAttackForces SET NumMeleeUnits = NumMeleeUnits * 2;  -- x2
UPDATE BarbarianAttackForces SET NumRangeUnits = NumRangeUnits * 2;  -- x2
UPDATE BarbarianAttackForces SET NumSiegeUnits = NumSiegeUnits * 2;  -- x2
UPDATE BarbarianAttackForces SET NumSupportUnits = NumSupportUnits * 2;  -- x2