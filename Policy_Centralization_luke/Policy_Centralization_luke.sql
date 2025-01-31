-- 1. 创建新政策 中央集权制度
INSERT INTO Types (Type, Kind) VALUES
('Policy_Centralization', 'KIND_POLICY');


-- 2. 政策的名称、描述、需要的槽位类型  中央集权制度  早期帝国解锁
INSERT INTO Policies (PolicyType, Name, Description, GovernmentSlotType,PrereqCivic) VALUES
("Policy_Centralization", "LOC_POLICY_CENTRALIZATION_NAME", "LOC_POLICY_CENTRALIZATION_DESCRIPTION", "SLOT_MILITARY","CIVIC_EARLY_EMPIRE");



/*
槽位类型：（详见 GovernmentSlots 表中）
    SLOT_MILITARY       军事
    SLOT_ECONOMIC       经济
    SLOT_DIPLOMATIC     外交
    SLOT_WILDCARD       通配符
    SLOT_GREAT_PERSON   伟人
*/



-----------------------------------------
-- 为该政策添加修改器 Modifier 
-----------------------------------------

INSERT INTO PolicyModifiers (PolicyType, ModifierId) VALUES 
("Policy_Centralization", "Modifier_Centralization_Change_Cities_Identity");

INSERT INTO Modifiers (ModifierId, ModifierType, RunOnce, Permanent, NewOnly, OwnerRequirementSetId, SubjectRequirementSetId) VALUES 
("Modifier_Centralization_Change_Cities_Identity", "MODIFIER_PLAYER_CITIES_ADJUST_IDENTITY_PER_TURN", 0, 0, 0, NULL, NULL);

INSERT INTO ModifierArguments (ModifierId, Name, Value) VALUES 
("Modifier_Centralization_Change_Cities_Identity", "Amount", 6);


-- 新增军功爵制 政策
-- 1. 创建新政策
INSERT INTO Types (Type, Kind) VALUES
('Policy_Militarymerit', 'KIND_POLICY');

INSERT INTO Policies (PolicyType, Name, Description, GovernmentSlotType,PrereqCivic) VALUES
("Policy_Militarymerit", "LOC_POLICY_Militarymerit_NAME", "LOC_POLICY_Militarymerit_DESCRIPTION", "SLOT_MILITARY","CIVIC_MILITARY_TRAINING");

-- 黄昏之力 2点战斗力  但是我废弃了，改直接新建修改器
--INSERT INTO PolicyModifiers (PolicyType, ModifierId) VALUES 
--("Policy_Militarymerit", "OLIGARCHY_MELEE");

--增加每个单位额外维护费2
INSERT INTO PolicyModifiers (PolicyType, ModifierId) VALUES 
("Policy_Militarymerit", "ELITEFORCES_EXTRA_MAINTENANCE");


-- 尝试写加战斗力的修改器效果  军功爵制战斗buff
INSERT INTO PolicyModifiers (PolicyType, ModifierId) VALUES ("Policy_Militarymerit", "Policy_Militarymerit_COMBAT_BONUS_MODIFIER");
--军功爵制 加战斗力6
INSERT INTO Modifiers (ModifierId, ModifierType, RunOnce, Permanent, NewOnly, OwnerRequirementSetId, SubjectRequirementSetId) VALUES ("Policy_Militarymerit_COMBAT_BONUS_MODIFIER","MODIFIER_PLAYER_UNITS_ADJUST_COMBAT_STRENGTH", 0, 0, 0, NULL, NULL);

INSERT INTO ModifierArguments (ModifierId, Name,Value) VALUES ("Policy_Militarymerit_COMBAT_BONUS_MODIFIER","Amount",6);

INSERT INTO ModifierStrings (ModifierId, Context, `Text`) VALUES ("Policy_Militarymerit_COMBAT_BONUS_MODIFIER","Preview","LOC_ABILITY_Policy_Militarymerit_COMBAT_BONUS_MODIFIER");




-- 1. 创建新政策  穷兵黩武
INSERT INTO Types (Type, Kind) VALUES
('Policy_ExcessiveMilitarism', 'KIND_POLICY');


-- 2. 政策的名称、描述、需要的槽位类型  
INSERT INTO Policies (PolicyType, Name, Description, GovernmentSlotType,PrereqCivic) VALUES
("Policy_ExcessiveMilitarism", "LOC_POLICY_ExcessiveMilitarism_NAME", "LOC_POLICY_ExcessiveMilitarism_DESCRIPTION", "SLOT_MILITARY","CIVIC_EARLY_EMPIRE");
/*
槽位类型：（详见 GovernmentSlots 表中）
    SLOT_MILITARY       军事
    SLOT_ECONOMIC       经济
    SLOT_DIPLOMATIC     外交
    SLOT_WILDCARD       通配符
    SLOT_GREAT_PERSON   伟人
*/



-----------------------------------------
-- 为该政策添加修改器 Modifier 
-----------------------------------------
--增加额外战斗力
INSERT INTO PolicyModifiers (PolicyType, ModifierId) VALUES 
("Policy_ExcessiveMilitarism", "TWILIGHTVALOR_MELEE_ATTACK_BONUS_2");

INSERT INTO Modifiers (ModifierId, ModifierType, RunOnce, Permanent, NewOnly, OwnerRequirementSetId, SubjectRequirementSetId) VALUES 
("TWILIGHTVALOR_MELEE_ATTACK_BONUS_2", "MODIFIER_PLAYER_UNITS_GRANT_ABILITY", 0, 0, 0, NULL, NULL);

INSERT INTO ModifierArguments (ModifierId, Name, Value) VALUES 
("TWILIGHTVALOR_MELEE_ATTACK_BONUS_2", "AbilityType", 'ABILITY_TWILIGHT_VALOR_ATTACK_BONUS');

-- 减忠诚 -4
INSERT INTO PolicyModifiers (PolicyType, ModifierId) VALUES 
("Policy_ExcessiveMilitarism", "Modifier_ExcessiveMilitarism_yieldloyal");

INSERT INTO Modifiers (ModifierId, ModifierType, RunOnce, Permanent, NewOnly, OwnerRequirementSetId, SubjectRequirementSetId) VALUES 
("Modifier_ExcessiveMilitarism_yieldloyal", "MODIFIER_PLAYER_CITIES_ADJUST_IDENTITY_PER_TURN", 0, 0, 0, NULL, NULL);

INSERT INTO ModifierArguments (ModifierId, Name, Value) VALUES 
("Modifier_ExcessiveMilitarism_yieldloyal", "Amount", -4);

-- 每个城市地块产出 减文化 33%
INSERT INTO PolicyModifiers (PolicyType, ModifierId) VALUES 
("Policy_ExcessiveMilitarism", "Modifier_ExcessiveMilitarism_yieldculture");

INSERT INTO Modifiers (ModifierId, ModifierType, RunOnce, Permanent, NewOnly, OwnerRequirementSetId, SubjectRequirementSetId) VALUES 
("Modifier_ExcessiveMilitarism_yieldculture", "MODIFIER_PLAYER_CITIES_ADJUST_CITY_YIELD_MODIFIER", 0, 0, 0, NULL, NULL);

INSERT INTO ModifierArguments (ModifierId, Name, Value) VALUES 
("Modifier_ExcessiveMilitarism_yieldculture", "Amount", -33);

INSERT INTO ModifierArguments (ModifierId, Name, Value) VALUES 
("Modifier_ExcessiveMilitarism_yieldculture", "YieldType", 'YIELD_CULTURE');

-- 新增胡服骑射 政策
-- 1. 创建新政策
INSERT INTO Types (Type, Kind) VALUES
('Policy_Steppe_Cavalry_Tactics', 'KIND_POLICY');

INSERT INTO Policies (PolicyType, Name, Description, GovernmentSlotType,PrereqCivic) VALUES
("Policy_Steppe_Cavalry_Tactics", "LOC_Policy_Steppe_Cavalry_Tactics_NAME", "LOC_Policy_Steppe_Cavalry_Tactics_DESCRIPTION", "SLOT_MILITARY","CIVIC_MILITARY_TRAINING");

INSERT INTO PolicyModifiers (PolicyType, ModifierId) VALUES 
("Policy_Steppe_Cavalry_Tactics", "TRAIT_COMBAT_BONUS_FOR_Steppe_CAVALRY");

INSERT INTO Modifiers (ModifierId, ModifierType, RunOnce, Permanent, NewOnly, OwnerRequirementSetId, SubjectRequirementSetId) VALUES 
("TRAIT_COMBAT_BONUS_FOR_Steppe_CAVALRY", "MODIFIER_PLAYER_UNITS_GRANT_ABILITY", 0, 0, 0, NULL, NULL);

INSERT INTO ModifierArguments (ModifierId, Name, Value) VALUES 
("TRAIT_COMBAT_BONUS_FOR_Steppe_CAVALRY", "AbilityType", "ABILITY_GENGHIS_KHAN_CAVALRY_BONUS");



--INSERT INTO ModifierStrings (ModifierId, Context, `Text`) VALUES ("TRAIT_COMBAT_BONUS_FOR_Steppe_CAVALRY","Preview","LOC_ABILITY_Policy_Militarymerit_COMBAT_BONUS_MODIFIER");