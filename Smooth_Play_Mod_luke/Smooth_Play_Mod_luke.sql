-- ADD Range
UPDATE Units SET Range = Range + 1 WHERE UnitType = 'UNIT_CHINESE_CROUCHING_TIGER';


-- 更新现有的 MONUMENT_LOYALTY 修改器

UPDATE ModifierArguments SET Value = 7 WHERE ModifierId = 'MONUMENT_LOYALTY' AND `Name` = 'Amount';


-- 国家奇观为所在城市增加1点宜居度

UPDATE Buildings SET Entertainment = Entertainment + 1 WHERE `IsWonder` = 1;

--占领别人的首都只减外交点数 1
UPDATE GlobalParameters SET Value='-1' WHERE `Name`='FAVOR_PER_OWNED_ORIGINAL_CAPITAL';

-- 将无守军的城市基础战斗力下调参数改到25，意思是无驻军城市战斗力-25
UPDATE GlobalParameters SET Value = '25' WHERE `Name` = 'COMBAT_GARRISON_MILITIA_MODIFIER';


-- 增加奢侈品的支持城市 至 6座城市
UPDATE 	Resources SET `Happiness` = "6" WHERE ResourceClassType="RESOURCECLASS_LUXURY";

-- 空中花园 再增加1宜居度
UPDATE Buildings SET Entertainment = Entertainment + 1 WHERE BuildingType ="BUILDING_HANGING_GARDENS";

UPDATE ModifierArguments SET `Value` = 35 WHERE ModifierId ="HANGING_GARDEN_ADDGROWTH" AND `Name`="Amount";

-- 减少工业区的开销 54--》40
UPDATE Districts SET Cost = 40 WHERE DistrictType ="DISTRICT_INDUSTRIAL_ZONE";

-- 减少军营的开销 54--》40
UPDATE Districts SET Cost = 40 WHERE DistrictType="DISTRICT_ENCAMPMENT";

-- 减少娱乐区的开销 54--》40
UPDATE Districts SET Cost = 40 WHERE DistrictType="DISTRICT_ENTERTAINMENT_COMPLEX";

-- 减少社区的开销 54--》40
UPDATE Districts SET Cost = 40 WHERE DistrictType="DISTRICT_NEIGHBORHOOD";



-- 减少造船术的开销 200--》160
UPDATE Technologies SET Cost = 160 WHERE TechnologyType ="TECH_SHIPBUILDING";


