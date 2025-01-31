--==========================================================================================================================
-- LEADERS
--==========================================================================================================================
-- Types
--------------------------------------------------------------------------------------------------------------------------	
INSERT INTO Types	
		(Type,							Kind)
VALUES	('LEADER_GEDEMO_NAPOLEON',	'KIND_LEADER');
		

--------------------------------------------------------------------------------------------------------------------------
-- Leaders
--------------------------------------------------------------------------------------------------------------------------	
INSERT INTO Leaders	
		(LeaderType,					Name,										InheritFrom,		SceneLayers)
VALUES	('LEADER_GEDEMO_NAPOLEON',	'LOC_LEADER_GEDEMO_NAPOLEON',		'LEADER_DEFAULT',	4);	
--------------------------------------------------------------------------------------------------------------------------
-- LeaderQuotes
--------------------------------------------------------------------------------------------------------------------------	
INSERT INTO LeaderQuotes	
		(LeaderType,			Quote)
VALUES	('LEADER_GEDEMO_NAPOLEON',	'LOC_PEDIA_LEADERS_PAGE_LEADER_GEDEMO_NAPOLEON_QUOTE');	

--==========================================================================================================================
-- LEADER: AGENDAS
--==========================================================================================================================
-- Types
--------------------------------------------------------------------------------------------------------------------------
INSERT INTO Types
		(Type,										Kind)
VALUES	('TRAIT_AGENDA_GEDEMO_NAPOLEON',		'KIND_TRAIT');
--------------------------------------------------------------------------------------------------------------------------
-- Agendas
--------------------------------------------------------------------------------------------------------------------------
INSERT INTO Agendas
		(AgendaType,								Name,										Description)
VALUES	('AGENDA_GEDEMO_NAPOLEON',				'LOC_AGENDA_GEDEMO_NAPOLEON_NAME',		'LOC_AGENDA_GEDEMO_NAPOLEON_DESCRIPTION');
--------------------------------------------------------------------------------------------------------------------------
-- Traits
--------------------------------------------------------------------------------------------------------------------------
INSERT INTO Traits
		(TraitType,									Name,										Description)
VALUES	('TRAIT_AGENDA_GEDEMO_NAPOLEON',		'LOC_PLACEHOLDER',							'LOC_PLACEHOLDER');
--------------------------------------------------------------------------------------------------------------------------
-- AgendaTraits
--------------------------------------------------------------------------------------------------------------------------
INSERT INTO AgendaTraits
		(AgendaType,								TraitType)
VALUES	('AGENDA_GEDEMO_NAPOLEON',				'TRAIT_AGENDA_SHORT_LIFE_GLORY');
--------------------------------------------------------------------------------------------------------------------------
-- ExclusiveAgendas
--------------------------------------------------------------------------------------------------------------------------
INSERT INTO ExclusiveAgendas
		(AgendaOne,									AgendaTwo)
VALUES	('AGENDA_GEDEMO_NAPOLEON',				'AGENDA_SHORT_LIFE_GLORY');

--------------------------------------------------------------------------------------------------------------------------
-- HistoricalAgendas
--------------------------------------------------------------------------------------------------------------------------
INSERT INTO HistoricalAgendas
		(LeaderType,				AgendaType)
VALUES	('LEADER_GEDEMO_NAPOLEON',	'AGENDA_GEDEMO_NAPOLEON');

--------------------------------------------------------------------------------------------------------------------------
-- AgendaPreferredLeaders
--------------------------------------------------------------------------------------------------------------------------	
INSERT INTO AgendaPreferredLeaders	
		(LeaderType,					AgendaType)
VALUES	('LEADER_GEDEMO_NAPOLEON',	'AGENDA_DARWINIST');	




--==========================================================================================================================
-- LEADERS: LOADING INFO
--==========================================================================================================================
-- LoadingInfo
--------------------------------------------------------------------------------------------------------------------------	
INSERT INTO LoadingInfo	
		(LeaderType,						BackgroundImage, 						ForegroundImage,						PlayDawnOfManAudio)
VALUES	('LEADER_GEDEMO_NAPOLEON',		'LEADER_NEUTRAL_BACKGROUND',		'LEADER_NAPOLEON_NEUTRAL',			0);	
--==========================================================================================================================
-- CIVILIZATIONS
--==========================================================================================================================
-- Types
----------------------------------------------------------------------------------------------------------------------------	

----------------------------------------------------------------------------------------------------------------------------
-- Civilizations
----------------------------------------------------------------------------------------------------------------------------	
INSERT INTO CivilizationLeaders	
		(CivilizationType,					LeaderType,										CapitalName)
VALUES	('CIVILIZATION_FRANCE',	'LEADER_GEDEMO_NAPOLEON',	'LOC_CITY_NAME_PARIS');	
----------------------------------------------------------------------------------------------------------------------------			

----------------------------------------------------------------------------------------------------------------------------			
-------------------------------------
-- CityNames
-------------------------------------
INSERT INTO CityNames	
			(CivilizationType,				LeaderType,					SortIndex,	CityName)	
VALUES		('CIVILIZATION_FRANCE',		'LEADER_GEDEMO_NAPOLEON',		-1,			'LOC_CITY_NAME_PARIS');	
			
--------------------------------------------------------------------------------------------------------------------------		
-- BackGround Art		
--------------------------------------------------------------------------------------------------------------------------			
INSERT INTO DiplomacyInfo			
		(Type,								BackgroundImage)
VALUES	('LEADER_GEDEMO_NAPOLEON',		'ART_LEADER_NAPOLEON.dds');

--------------------------------------------------------------------------------------------------------------------------	
-- Types
--------------------------------------------------------------------------------------------------------------------------	

INSERT INTO Types	
		(Type,														Kind)
VALUES	('TRAIT_LEADER_GEDEMO_NAPOLEON',						'KIND_TRAIT');

--------------------------------------------------------------------------------------------------------------------------			
-- Traits			
--------------------------------------------------------------------------------------------------------------------------				
INSERT INTO Traits				
		(TraitType,													Name,													Description)
VALUES	('TRAIT_LEADER_GEDEMO_NAPOLEON',						'LOC_TRAIT_LEADER_GEDEMO_NAPOLEON_NAME',			'LOC_TRAIT_LEADER_GEDEMO_NAPOLEON_DESCRIPTION');	

--------------------------------------------------------------------------------------------------------------------------
-- LeaderTraits
--------------------------------------------------------------------------------------------------------------------------	
INSERT INTO LeaderTraits	
		(LeaderType,			TraitType)
VALUES	('LEADER_GEDEMO_NAPOLEON',	'TRAIT_LEADER_GEDEMO_NAPOLEON');
		


-----------------------------------------------
-- TraitModifiers
-----------------------------------------------

INSERT INTO	TraitModifiers
		(TraitType,									ModifierId		)	
VALUES	('TRAIT_LEADER_GEDEMO_NAPOLEON',	'LEADER_NAPOLEON_DIPLOMATIC'),
		('TRAIT_LEADER_GEDEMO_NAPOLEON',	'TRAIT_NAPOLEON_UNITMAINTENANCEDISCOUNT'),
		('TRAIT_LEADER_GEDEMO_NAPOLEON',	'TRAIT_BOOSTNAP_ENCAMPMENT_PRODUCTION'	);



-----------------------------------------------
-- Modifiers
-----------------------------------------------

INSERT INTO	Modifiers
		(ModifierId,											ModifierType,								RunOnce, Permanent, OwnerRequirementsetId)
VALUES	('LEADER_NAPOLEON_DIPLOMATIC',	'MODIFIER_PLAYER_CULTURE_ADJUST_GOVERNMENT_SLOTS_MODIFIER',	1, 1, 'PLAYER_HAS_SCIENCE_TECHNOLOGY_FRANCE'),
		('TRAIT_NAPOLEON_UNITMAINTENANCEDISCOUNT',	'MODIFIER_PLAYER_ADJUST_UNIT_MAINTENANCE_DISCOUNT',	0, 0, NULL),
		('TRAIT_BOOSTNAP_ENCAMPMENT_PRODUCTION',	'MODIFIER_PLAYER_CITIES_ADJUST_DISTRICT_PRODUCTION',	0, 0, NULL);

-----------------------------------------------
-- ModifierArguments
-----------------------------------------------

INSERT INTO	ModifierArguments
		(ModifierId,												Name,		Value	)
VALUES	('LEADER_NAPOLEON_DIPLOMATIC',		'GovernmentSlotType',	'SLOT_MILITARY'		),
		('TRAIT_BOOSTNAP_ENCAMPMENT_PRODUCTION',		'DistrictType',	'DISTRICT_ENCAMPMENT'		),
		('TRAIT_NAPOLEON_UNITMAINTENANCEDISCOUNT',		'Amount',	1		),
		('TRAIT_BOOSTNAP_ENCAMPMENT_PRODUCTION',		'Amount',	'100'		);

-----------------------------------------------
-- RequirementSetRequirements
-----------------------------------------------

INSERT INTO RequirementSetRequirements
		(RequirementSetId,										RequirementId										)
VALUES	('PLAYER_HAS_SCIENCE_TECHNOLOGY_FRANCE',		'REQUIRES_TECHNOLOGY_SCIENCE_FRANCE'		);

-----------------------------------------------
-- RequirementSets
-----------------------------------------------

INSERT INTO RequirementSets
		(RequirementSetId,									RequirementSetType			)
VALUES	('PLAYER_HAS_SCIENCE_TECHNOLOGY_FRANCE',	'REQUIREMENTSET_TEST_ALL'	);

-----------------------------------------------
-- Requirements
-----------------------------------------------

INSERT INTO Requirements
		(RequirementId,											RequirementType)
VALUES	('REQUIRES_TECHNOLOGY_SCIENCE_FRANCE',			'REQUIREMENT_PLAYER_HAS_TECHNOLOGY');

-----------------------------------------------
-- RequirementArguments
-----------------------------------------------
		
INSERT INTO RequirementArguments
		(RequirementId,										Name,			Value					)
VALUES	('REQUIRES_TECHNOLOGY_SCIENCE_FRANCE',		'TechnologyType',	'TECH_MILITARY_SCIENCE'	);

-----------------------------------------------
-- AiListTypes
-----------------------------------------------

INSERT INTO AiListTypes
		(ListType										)
VALUES 	('LEADER_GEDEMO_NAPOLEON_TECHS'			),
		('LEADER_GEDEMO_NAPOLEON_CIVICS'		),
		('LEADER_GEDEMO_NAPOLEON_DISTRICTS'		),
		('LEADER_GEDEMO_NAPOLEON_BUILDINGS'		),
		('LEADER_GEDEMO_NAPOLEON_DIPLOMACY'		),
		('LEADER_GEDEMO_NAPOLEON_EXPANSION'		),
		('LEADER_GEDEMO_NAPOLEON_PSEUDOS'		);

-----------------------------------------------
-- AiLists
-----------------------------------------------

INSERT INTO AiLists
		(ListType,										LeaderType,								System						)
VALUES  ('LEADER_GEDEMO_NAPOLEON_TECHS',		'TRAIT_LEADER_GEDEMO_NAPOLEON',	'Technologies'				),
		('LEADER_GEDEMO_NAPOLEON_CIVICS',		'TRAIT_LEADER_GEDEMO_NAPOLEON',	'Civics'					),
		('LEADER_GEDEMO_NAPOLEON_DISTRICTS',	'TRAIT_LEADER_GEDEMO_NAPOLEON',	'Districts'					),
		('LEADER_GEDEMO_NAPOLEON_BUILDINGS',	'TRAIT_LEADER_GEDEMO_NAPOLEON',	'Buildings'					);
		
		
-----------------------------------------------
-- AiFavoredItems
-----------------------------------------------

INSERT INTO AiFavoredItems
		(ListType,										Item,										Favored,	StringVal		)
VALUES  -- TECHS
		('LEADER_GEDEMO_NAPOLEON_TECHS',		'TECH_MILITARY_SCIENCE',								1,			NULL						),
		('LEADER_GEDEMO_NAPOLEON_TECHS',		'TECH_MILITARY_ENGINEERING',						1,			NULL						),
		('LEADER_GEDEMO_NAPOLEON_TECHS',		'TECH_HORSEBACK_RIDING',						1,			NULL						),
		('LEADER_GEDEMO_NAPOLEON_TECHS',		'TECH_IRON_WORKING',							1,			NULL						),
		
		-- CIVICS
		('LEADER_GEDEMO_NAPOLEON_CIVICS',		'CIVIC_MILITARY_TRADITION',					1,			NULL						),
		('LEADER_GEDEMO_NAPOLEON_CIVICS',		'CIVIC_DEFENSIVE_TACTICS',					1,			NULL						),
		('LEADER_GEDEMO_NAPOLEON_CIVICS',		'CIVIC_MILITARY_TRAINING',						1,			NULL						),
		('LEADER_GEDEMO_NAPOLEON_CIVICS',		'CIVIC_DRAMA_POETRY',						1,			NULL						),
		
		
		-- WONDERS
		('LEADER_GEDEMO_NAPOLEON_BUILDINGS',	'BUILDING_BARRACKS',							1,			NULL						),
		('LEADER_GEDEMO_NAPOLEON_BUILDINGS',	'BUILDING_EIFFEL_TOWER',						1,			NULL						),
		('LEADER_GEDEMO_NAPOLEON_BUILDINGS',	'BUILDING_STAR_FORT',					1,			NULL						),
		
		-- DISTRICTS
		('LEADER_GEDEMO_NAPOLEON_DISTRICTS',	'DISTRICT_ENCAMPMENT',						1,			NULL						),
		('LEADER_GEDEMO_NAPOLEON_DISTRICTS',	'DISTRICT_THEATER',						1,			NULL						);