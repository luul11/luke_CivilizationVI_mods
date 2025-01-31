-- RAID4
-- Author: james_pham
-- DateCreated: 25-Oct-24 12:10:36 AM
--------------------------------------------------------------
-- Update Barbarian Raid Numbers for x4
UPDATE BarbarianAttackForces SET NumMeleeUnits = NumMeleeUnits * 4;  -- x4
UPDATE BarbarianAttackForces SET NumRangeUnits = NumRangeUnits * 4;  -- x4
UPDATE BarbarianAttackForces SET NumSiegeUnits = NumSiegeUnits * 4;  -- x4
UPDATE BarbarianAttackForces SET NumSupportUnits = NumSupportUnits * 4;  -- x4