-- NAV1
-- Author: james_pham
-- DateCreated: 29-Nov-24 5:07:10 PM
--------------------------------------------------------------
--UPDATE BarbarianTribes
--SET ScoutTag = 'CLASS_NAVAL_MELEE',
	--MeleeTag = 'CLASS_NAVAL_MELEE',
	--RangedTag = 'CLASS_NAVAL_RANGED',
	--SiegeTag = 'CLASS_NAVAL_RANGED',
	--SupportTag = NULL,
	--IsCoastal = 1
--WHERE TribeType = 'TRIBE_CLAN_NAVAL'
	--OR TribeType = 'TRIBE_NAVAL';

UPDATE GlobalParameters SET Value = 3 WHERE Name = 'BARBARIAN_CAMP_COASTAL_SPAWN_ROLL';