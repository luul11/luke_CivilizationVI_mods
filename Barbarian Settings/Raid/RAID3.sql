-- RAID3
-- Author: james_pham
-- DateCreated: 25-Oct-24 12:10:32 AM
--------------------------------------------------------------
-- Update Barbarian Raid Numbers for x3
UPDATE BarbarianAttackForces SET NumMeleeUnits = NumMeleeUnits * 3;  -- x3
UPDATE BarbarianAttackForces SET NumRangeUnits = NumRangeUnits * 3;  -- x3
UPDATE BarbarianAttackForces SET NumSiegeUnits = NumSiegeUnits * 3;  -- x3
UPDATE BarbarianAttackForces SET NumSupportUnits = NumSupportUnits * 3;  -- x3