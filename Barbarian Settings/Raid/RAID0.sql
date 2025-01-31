-- RAID0
-- Author: james_pham
-- DateCreated: 14-Nov-24 8:52:53 PM
--------------------------------------------------------------
UPDATE BarbarianAttackForces SET NumMeleeUnits = (NumMeleeUnits + 1) / 2;  -- /2 and round up
UPDATE BarbarianAttackForces SET NumRangeUnits = (NumRangeUnits + 1) / 2;  -- /2 and round up
UPDATE BarbarianAttackForces SET NumSiegeUnits = (NumSiegeUnits + 1) / 2;  -- /2 and round up
UPDATE BarbarianAttackForces SET NumSupportUnits = (NumSupportUnits + 1) / 2;  -- /2 and round up
