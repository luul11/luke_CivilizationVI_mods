-- NAV0
-- Author: james_pham
-- DateCreated: 29-Nov-24 5:07:03 PM
--------------------------------------------------------------
UPDATE BarbarianTribes
SET ScoutTag = 'CLASS_RECON',
	MeleeTag = 'CLASS_MELEE',
	RangedTag = 'CLASS_RANGED',
	SiegeTag = 'CLASS_SIEGE',
	SupportTag = 'CLASS_BATTERING_RAM',
	IsCoastal = 0
WHERE TribeType = 'TRIBE_CLAN_NAVAL'
	OR TribeType = 'TRIBE_NAVAL';

UPDATE BarbarianTribeForces
SET TribeType = 'TRIBE_MELEE'
WHERE TribeType = 'TRIBE_NAVAL';

UPDATE BarbarianTribeForces
SET TribeType = 'TRIBE_CLAN_MELEE_OPEN'
WHERE TribeType = 'TRIBE_CLAN_NAVAL';

UPDATE BarbarianAttackForces
SET MeleeTag = 'CLASS_MELEE'
WHERE MeleeTag = 'CLASS_NAVAL_MELEE';

UPDATE BarbarianAttackForces
SET RangeTag = 'CLASS_RANGED'
WHERE RangeTag = 'CLASS_NAVAL_RANGED';

UPDATE BarbarianAttackForces
SET SiegeTag = 'CLASS_SIEGE'
WHERE SiegeTag = 'CLASS_NAVAL_RANGED';

UPDATE BarbarianAttackForces
SET SupportTag = 'CLASS_BATTERING_RAM'
WHERE AttackForceType IN ('NavalAttack', 'HighDifficultyNavalAttack');

UPDATE GlobalParameters SET Value = 0 WHERE Name = 'BARBARIAN_CAMP_COASTAL_SPAWN_ROLL';