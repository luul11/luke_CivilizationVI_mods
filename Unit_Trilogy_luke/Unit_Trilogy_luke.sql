--==========================================================================================================================
-- Units
--==========================================================================================================================
-- Types
-----------------------------------------------------------------------------------	
INSERT INTO Types	
			(Type,													Kind)
VALUES		('UNIT_CN_TRILOGY',								'KIND_UNIT');

INSERT INTO Types	
			(Type,													Kind)
VALUES		('TRAIT_UNIT_CN_TRILOGY',								'KIND_TRAIT');

INSERT INTO Traits				
		(TraitType,										Name,											Description)
VALUES	('TRAIT_UNIT_CN_TRILOGY',			'LOC_UNIT_CN_TRILOGY_NAME',	'LOC_UNIT_CN_TRILOGY_DESCRIPTION');


INSERT INTO TraitModifiers (TraitType, ModifierId) VALUES ('TRAIT_UNIT_CN_TRILOGY', 'MAMLUK_HEAL_EVERY_MOVE');




-----------------------------------------------------------------------------------
-- Units
-----------------------------------------------------------------------------------
INSERT INTO Units
			(UnitType,								Name, 											Description, 									TraitType,											Combat,		BaseMoves,		Cost,	AdvisorType, BaseSightRange, ZoneOfControl, Domain, FormationClass, PurchaseYield, PromotionClass, Maintenance,		MandatoryObsoleteTech, PrereqTech,StrategicResource)
SELECT 		'UNIT_CN_TRILOGY',				'LOC_UNIT_CN_TRILOGY_NAME',				'LOC_UNIT_CN_TRILOGY_DESCRIPTION',		'TRAIT_UNIT_CN_TRILOGY',				Combat+5,		BaseMoves,	Cost-20,	AdvisorType, BaseSightRange, ZoneOfControl, Domain, FormationClass, PurchaseYield, PromotionClass, Maintenance,		MandatoryObsoleteTech, PrereqTech,StrategicResource
FROM Units WHERE UnitType = 'UNIT_SWORDSMAN';
-----------------------------------------------------------------------------------
-- UnitUpgrades
-----------------------------------------------------------------------------------
INSERT INTO UnitUpgrades
			(Unit,								UpgradeUnit)
SELECT 		'UNIT_CN_TRILOGY',		UpgradeUnit
FROM UnitUpgrades WHERE Unit = 'UNIT_SWORDSMAN';
-----------------------------------------------------------------------------------
-- UnitAiInfos
-----------------------------------------------------------------------------------
INSERT INTO UnitAiInfos
			(UnitType,							AiType)
SELECT 		'UNIT_CN_TRILOGY',		AiType
FROM UnitAiInfos WHERE UnitType = 'UNIT_SWORDSMAN';
-----------------------------------------------------------------------------------
-- UnitReplaces
-----------------------------------------------------------------------------------
INSERT INTO UnitReplaces
			(CivUniqueUnitType,					ReplacesUnitType)
VALUES		('UNIT_CN_TRILOGY',		'UNIT_SWORDSMAN');
-----------------------------------------------------------------------------------
-- TypeTags
-----------------------------------------------------------------------------------


INSERT INTO CivilizationTraits
			(CivilizationType,					TraitType)
VALUES		('CIVILIZATION_CHINA',		'TRAIT_UNIT_CN_TRILOGY');

INSERT INTO Units_XP2
			(UnitType,					ResourceCost)
VALUES		('UNIT_CN_TRILOGY',		20);

