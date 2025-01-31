-- GameData1
-- Author: user
-- DateCreated: 5/30/2018 10:01:08 PM
--------------------------------------------------------------
-----------------------------------------------
-- 40sw4rm's Old World
-----------------------------------------------

CREATE TABLE IF NOT EXISTS TSL 
    (
    MapType		TEXT	DEFAULT NULL,
    Civ			TEXT	DEFAULT NULL,
    LeaderType	TEXT	DEFAULT NULL,
    X			INTEGER	DEFAULT	NULL,
    Y			INTEGER	DEFAULT NULL
    );

INSERT INTO TSL
		(MapType,		Civ,							LeaderType,				X,	Y	)
VALUES	('40sw4rmOW',	'CIVILIZATION_FRANCE',	'LEADER_GEDEMO_NAPOLEON',		14,	58	);
		