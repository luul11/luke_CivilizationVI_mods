INSERT INTO Types
	(Type,											Kind)
VALUES
	('TRAIT_GOLD_PURCHASE',							'KIND_TRAIT');

INSERT INTO Traits
	(TraitType)
VALUES
	('TRAIT_GOLD_PURCHASE');

INSERT INTO LeaderTraits
	(LeaderType,									TraitType)
SELECT
	LeaderType,										'TRAIT_GOLD_PURCHASE'
FROM Leaders WHERE InheritFrom = 'LEADER_DEFAULT';

INSERT INTO GlobalParameters
	(Name,											Value)
VALUES
	('HUAN_GOLD_PURCHASE_PRODUCTION_EFFICIENCY',	0.25);