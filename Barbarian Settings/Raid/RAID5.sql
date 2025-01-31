-- RAID5
-- Author: james_pham
-- DateCreated: 25-Oct-24 12:10:41 AM
--------------------------------------------------------------
-- Update Barbarian Raid Numbers for x5
UPDATE BarbarianAttackForces SET NumMeleeUnits = NumMeleeUnits * 5;  -- x5
UPDATE BarbarianAttackForces SET NumRangeUnits = NumRangeUnits * 5;  -- x5
UPDATE BarbarianAttackForces SET NumSiegeUnits = NumSiegeUnits * 5;  -- x5
UPDATE BarbarianAttackForces SET NumSupportUnits = NumSupportUnits * 5;  -- x5
