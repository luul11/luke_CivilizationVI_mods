

--==========================================================================================================================
-- Historical Religions
--==========================================================================================================================
-- FavoredReligions 
------------------------------------------------------------

DELETE FROM FavoredReligions WHERE LeaderType = 'LEADER_GEDEMO_NAPOLEON';

INSERT OR REPLACE INTO FavoredReligions
           (LeaderType,                                       ReligionType)
SELECT   ('LEADER_GEDEMO_NAPOLEON'),                             ('RELIGION_CATHOLICISM')
WHERE NOT EXISTS (SELECT * FROM Religions WHERE ReligionType = 'RELIGION_CATHOLICISM');

INSERT OR REPLACE INTO FavoredReligions
           (LeaderType,                                       ReligionType)
SELECT   ('LEADER_GEDEMO_NAPOLEON'),                             ('RELIGION_CATHOLICISM')
WHERE EXISTS (SELECT * FROM Religions WHERE ReligionType = 'RELIGION_CATHOLICISM');



--==========================================================================================================================
-- GEDEMON YNAEMP
--==========================================================================================================================
-- StartPosition 
------------------------------------------------------------	
CREATE TABLE IF NOT EXISTS StartPosition (MapName TEXT, Civilization TEXT, Leader TEXT, X INT default 0, Y INT default 0);
INSERT INTO StartPosition
		(Civilization,						Leader,						MapName,			X,	Y)
VALUES	('CIVILIZATION_FRANCE',	'LEADER_GEDEMO_NAPOLEON',	'GiantEarth',		12,	67),
		('CIVILIZATION_FRANCE',	'LEADER_GEDEMO_NAPOLEON',	'GreatestEarthMap', 42,	48),
		('CIVILIZATION_FRANCE',	'LEADER_GEDEMO_NAPOLEON',	'LargestEarthCustom', 18,	84),
		('CIVILIZATION_FRANCE',	'LEADER_GEDEMO_NAPOLEON',	'LargeEurope', 27,	42),
		('CIVILIZATION_FRANCE',	'LEADER_GEDEMO_NAPOLEON',	'PlayEuropeAgain', 33,	52),
		('CIVILIZATION_FRANCE',	'LEADER_GEDEMO_NAPOLEON',	'Zobtzler_NorthernEurope_Map', 19,	1),
		('CIVILIZATION_FRANCE',  'LEADER_GEDEMO_NAPOLEON',  'CordiformEarth',  33, 29);

