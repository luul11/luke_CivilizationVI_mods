-- RAID1
-- Author: james_pham
-- DateCreated: 25-Oct-24 12:10:21 AM
--------------------------------------------------------------
-- Update Barbarian Raid Numbers for x1
UPDATE BarbarianAttackForces SET NumMeleeUnits = NumMeleeUnits * 1;  -- x1
UPDATE BarbarianAttackForces SET NumRangeUnits = NumRangeUnits * 1;  -- x1
UPDATE BarbarianAttackForces SET NumSiegeUnits = NumSiegeUnits * 1;  -- x1
UPDATE BarbarianAttackForces SET NumSupportUnits = NumSupportUnits * 1;  -- x1