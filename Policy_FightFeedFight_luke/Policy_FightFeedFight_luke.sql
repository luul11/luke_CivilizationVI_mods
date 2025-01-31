-- 1. 创建新政策 以战养战制度
INSERT INTO Types (Type, Kind) VALUES
("Policy_FightFeedFight", "KIND_POLICY");


-- 2. 政策的名称、描述、需要的槽位类型  
INSERT INTO Policies (PolicyType, Name, Description, GovernmentSlotType,PrereqCivic) VALUES
("Policy_FightFeedFight", "LOC_Policy_FightFeedFight_NAME", "LOC_Policy_FightFeedFight_DESCRIPTION", "SLOT_MILITARY","CIVIC_MILITARY_TRAINING");

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
("Policy_FightFeedFight", "Modifier_Policy_FightFeedFight");

INSERT INTO Modifiers (ModifierId, ModifierType, RunOnce, Permanent, NewOnly, OwnerRequirementSetId, SubjectRequirementSetId) VALUES 
("Modifier_Policy_FightFeedFight", "MODIFIER_PLAYER_ADJUST_DISTRICT_PILLAGE", 0, 0, 0, NULL, NULL);

INSERT INTO ModifierArguments (ModifierId, `Name`, `Value`) VALUES 
("Modifier_Policy_FightFeedFight", "Amount", 100);


-- 扫荡 政策前置从军事训练提前到军事传统
UPDATE Policies SET PrereqCivic="CIVIC_MILITARY_TRADITION" WHERE PolicyType="POLICY_RAID" and PrereqCivic="CIVIC_MILITARY_TRAINING";

--政策升级  扫荡-》以战养战-》全面战争

INSERT INTO ObsoletePolicies (PolicyType , ObsoletePolicy) VALUES ("Policy_FightFeedFight", "POLICY_TOTAL_WAR");

UPDATE ObsoletePolicies SET ObsoletePolicy="Policy_FightFeedFight" WHERE PolicyType="POLICY_RAID" and ObsoletePolicy="POLICY_TOTAL_WAR";




-- 效果改成100
UPDATE ModifierArguments SET `Amount`=100 WHERE ModifierId="TOTAL_WAR_PLUNDER_BONUS" and `Name`="Amount";


