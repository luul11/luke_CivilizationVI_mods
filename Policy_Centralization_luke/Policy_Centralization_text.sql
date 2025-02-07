-- 英文翻译
INSERT INTO LocalizedText (Language, Tag, Text)
VALUES
('en_US', 'LOC_POLICY_CENTRALIZATION_NAME', 'Centralization'),
('en_US', 'LOC_POLICY_CENTRALIZATION_DESCRIPTION', '+6 Identity per turn for each city.');

-- 简体中文翻译
INSERT INTO LocalizedText (Language, Tag, Text)
VALUES
('zh_Hans_CN', 'LOC_POLICY_CENTRALIZATION_NAME', '中央集权'),
('zh_Hans_CN', 'LOC_POLICY_CENTRALIZATION_DESCRIPTION', '每个城市每回合+6认同度（忠诚）');

-- 英文翻译
INSERT INTO LocalizedText (Language, Tag, Text)
VALUES
('en_US', 'LOC_POLICY_Militarymerit_NAME', 'Military Merit System'),
('zh_Hans_CN', 'LOC_POLICY_Militarymerit_NAME', '军功爵制'),
('en_US', 'LOC_POLICY_Militarymerit_DESCRIPTION', '+6 combat strength.+2 [ICON_Gold] EXTRA_MAINTENANCE'),
('zh_Hans_CN', 'LOC_POLICY_Militarymerit_DESCRIPTION', '所有单位战斗力+6，但额外+2 [ICON_Gold] 每单位维护费');

INSERT INTO LocalizedText (Language, Tag, Text)
VALUES
('en_US', 'LOC_ABILITY_Policy_Militarymerit_COMBAT_BONUS_MODIFIER', '+6 [ICON_Strength] combat strength'),
('zh_Hans_CN', 'LOC_ABILITY_Policy_Militarymerit_COMBAT_BONUS_MODIFIER', '军功爵制加6 [ICON_Strength] 战斗力');


-- 废弃

--REPLACE INTO LocalizedText (Language, Tag, Text)
--VALUES ('zh_Hans_CN', 'LOC_ABILITY_OLIGARCHY_MELEE_BUFF_MODIFIER_DESCRIPTION', '寡头政体或者军功爵制+4 [ICON_Strength] 战斗力。');


--REPLACE INTO LocalizedText (Language, Tag, Text)
--VALUES ('en_US', 'LOC_ABILITY_OLIGARCHY_MELEE_BUFF_MODIFIER_DESCRIPTION', 'Oligarchy or Military Merit System +4 [ICON_Strength] Combat Strength');



-- 穷兵黩武英文翻译
INSERT INTO LocalizedText (Language, Tag, Text)
VALUES
('en_US', 'LOC_POLICY_ExcessiveMilitarism_NAME', 'Excessive Militarism'),
('en_US', 'LOC_POLICY_ExcessiveMilitarism_DESCRIPTION', 'Increases additional melee combat power, reduces tile culture output by 33%, and reduces loyalty by 4 per city');


-- 穷兵黩武简体中文翻译
INSERT INTO LocalizedText (Language, Tag, Text)
VALUES
('zh_Hans_CN', 'LOC_POLICY_ExcessiveMilitarism_NAME', '穷兵黩武'),
('zh_Hans_CN', 'LOC_POLICY_ExcessiveMilitarism_DESCRIPTION', '增加额外近战战斗力5，减少地块文化产出33%，每个城市减忠诚4');



-- 英文翻译
INSERT INTO LocalizedText (Language, Tag, Text)
VALUES
('en_US', 'LOC_Policy_Steppe_Cavalry_Tactics_NAME', 'Steppe Cavalry Tactics'),
('en_US', 'LOC_Policy_Steppe_Cavalry_Tactics_DESCRIPTION', 'Steppe Cavalry Tactics，+3 [ICON_Strength] Combat Strength');

-- 简体中文翻译
INSERT INTO LocalizedText (Language, Tag, Text)
VALUES
('zh_Hans_CN', 'LOC_Policy_Steppe_Cavalry_Tactics_NAME', '胡服骑射'),
('zh_Hans_CN', 'LOC_Policy_Steppe_Cavalry_Tactics_DESCRIPTION', '草原游骑战术，+3 [ICON_Strength] 战斗力。');


--REPLACE INTO LocalizedText (Language, Tag, Text) VALUES ('zh_Hans_CN', 'LOC_LEADER_CAVALRY_COMBAT_BONUS_PREVIEW_TEXT', '+{1_Amount}蒙古部落或游牧战术');


--REPLACE INTO LocalizedText (Language, Tag, Text) VALUES ('en_US', 'LOC_LEADER_CAVALRY_COMBAT_BONUS_PREVIEW_TEXT', '+{1_Amount}Mongol or nomadic tribes');

UPDATE LocalizedText 
SET `Text` = '+{1_Amount}蒙古部落或游牧战术'
WHERE Language = 'zh_Hans_CN' AND Tag = 'LOC_LEADER_CAVALRY_COMBAT_BONUS_PREVIEW_TEXT';

UPDATE LocalizedText 
SET `Text` = '+{1_Amount}Mongol or nomadic tribes'
WHERE Language = 'en_US' AND Tag = 'LOC_LEADER_CAVALRY_COMBAT_BONUS_PREVIEW_TEXT';


--UPDATE LocalizedText SET Text = '+{1_Amount}蒙古部落或游牧战术' WHERE Language = 'zh_Hans_CN' AND Tag = 'LOC_LEADER_CAVALRY_COMBAT_BONUS_PREVIEW_TEXT';



