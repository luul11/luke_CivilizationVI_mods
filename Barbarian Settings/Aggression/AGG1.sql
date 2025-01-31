-- AGG1
-- Author: james_pham
-- DateCreated: 24-Oct-24 11:01:08 PM
--------------------------------------------------------------
-- Update for Barbarian Boldness per Camp Attack
UPDATE GlobalParameters SET Value=-30 WHERE Name='BARBARIAN_BOLDNESS_PER_CAMP_ATTACK';  -- Level 1

-- Update for Barbarian Boldness per Kill
UPDATE GlobalParameters SET Value=15 WHERE Name='BARBARIAN_BOLDNESS_PER_KILL';  -- Level 1

-- Update for Barbarian Boldness per Scout Lost
UPDATE GlobalParameters SET Value=-5 WHERE Name='BARBARIAN_BOLDNESS_PER_SCOUT_LOST';   -- Level 1

-- Update for Barbarian Boldness per Turn
UPDATE GlobalParameters SET Value=2 WHERE Name='BARBARIAN_BOLDNESS_PER_TURN';  -- Level 1

-- Update for Barbarian Boldness per Unit Lost
UPDATE GlobalParameters SET Value=-10 WHERE Name='BARBARIAN_BOLDNESS_PER_UNIT_LOST'; -- Level 1

-- Max actions per raid
UPDATE GlobalParameters SET Value = 18 WHERE Name = 'BARBARIAN_MAX_THROTTLE_PER_RAID';
-- How defensive playstyle they are. The lower number, they play fortified instead of attacking
UPDATE GlobalParameters SET Value = 4 WHERE Name = 'BARBARIAN_DEFENSE_ALL_UNITS';
UPDATE GlobalParameters SET Value = 1 WHERE Name = 'BARBARIAN_DEFENSE_RANGED_UNITS';

-- Adjust the intensity of barbarian responses or influence game dynamics based on interactions between your civilization and barbarian forces
UPDATE GlobalParameters SET Value = 2.0 WHERE Name = 'MAYHEM_CITY_DEATH_WITH_BARBARIANS';
UPDATE GlobalParameters SET Value = 0.5 WHERE Name = 'MAYHEM_DISTRICT_DEATH_WITH_BARBARIANS';
UPDATE GlobalParameters SET Value = 0.5 WHERE Name = 'MAYHEM_UNIT_COMBAT_WITH_BARBARIANS';
UPDATE GlobalParameters SET Value = 0.5 WHERE Name = 'MAYHEM_UNIT_DEATH_WITH_BARBARIANS';

-- More boldness factors
UPDATE BarbarianTribes SET RaidingBoldness = 10 WHERE TribeType = 'TRIBE_NAVAL';
UPDATE BarbarianTribes SET RaidingBoldness = 10 WHERE TribeType = 'TRIBE_CAVALRY';
UPDATE BarbarianTribes SET RaidingBoldness = 10 WHERE TribeType = 'TRIBE_MELEE';

UPDATE BarbarianTribes SET CityAttackBoldness = 10 WHERE TribeType = 'TRIBE_NAVAL';
UPDATE BarbarianTribes SET CityAttackBoldness = 10 WHERE TribeType = 'TRIBE_CAVALRY';
UPDATE BarbarianTribes SET CityAttackBoldness = 10 WHERE TribeType = 'TRIBE_MELEE';

-- Barbarian Clan
UPDATE BarbarianTribes SET RaidingBoldness = 10 WHERE TribeType = 'TRIBE_CLAN_MELEE_OPEN';
UPDATE BarbarianTribes SET RaidingBoldness = 15 WHERE TribeType = 'TRIBE_CLAN_MELEE_FOREST';
UPDATE BarbarianTribes SET RaidingBoldness = 15 WHERE TribeType = 'TRIBE_CLAN_MELEE_HILLS';
UPDATE BarbarianTribes SET RaidingBoldness = 20 WHERE TribeType = 'TRIBE_CLAN_CAVALRY_OPEN';
UPDATE BarbarianTribes SET RaidingBoldness = 20 WHERE TribeType = 'TRIBE_CLAN_CAVALRY_JUNGLE';
UPDATE BarbarianTribes SET RaidingBoldness = 20 WHERE TribeType = 'TRIBE_CLAN_CAVALRY_CHARIOT';
UPDATE BarbarianTribes SET RaidingBoldness = 15 WHERE TribeType = 'TRIBE_CLAN_NAVAL';

UPDATE BarbarianTribes SET CityAttackBoldness = 10 WHERE TribeType = 'TRIBE_CLAN_MELEE_OPEN';
UPDATE BarbarianTribes SET CityAttackBoldness = 15 WHERE TribeType = 'TRIBE_CLAN_MELEE_FOREST';
UPDATE BarbarianTribes SET CityAttackBoldness = 15 WHERE TribeType = 'TRIBE_CLAN_MELEE_HILLS';
UPDATE BarbarianTribes SET CityAttackBoldness = 20 WHERE TribeType = 'TRIBE_CLAN_CAVALRY_OPEN';
UPDATE BarbarianTribes SET CityAttackBoldness = 20 WHERE TribeType = 'TRIBE_CLAN_CAVALRY_JUNGLE';
UPDATE BarbarianTribes SET CityAttackBoldness = 20 WHERE TribeType = 'TRIBE_CLAN_CAVALRY_CHARIOT';
UPDATE BarbarianTribes SET CityAttackBoldness = 15 WHERE TribeType = 'TRIBE_CLAN_NAVAL';