-- 英文翻译
INSERT INTO LocalizedText (Language, Tag, Text)
VALUES
("en_US", "LOC_Policy_FightFeedFight_NAME", "Fight Feed Fight"),
("en_US", "LOC_Policy_FightFeedFight_DESCRIPTION", "Profit from plundering and coastal sweeping+100 %");

-- 简体中文翻译
INSERT INTO LocalizedText (Language, Tag, Text)
VALUES
("zh_Hans_CN", "LOC_Policy_FightFeedFight_NAME", "以战养战"),
("zh_Hans_CN", "LOC_Policy_FightFeedFight_DESCRIPTION", "掠夺和海岸扫荡的收益+100%");


-- 没有生效 应该还是加载顺序的问题
UPDATE LocalizedText SET `Text` = "掠夺、海岸扫荡和掠夺 [ICON_TradeRoute] 贸易路线的收益+100%。" WHERE `Language` = "zh_Hans_CN" AND `Tag` = "LOC_POLICY_TOTAL_WAR_EXPANSION1_ALT_DESCRIPTION";

UPDATE LocalizedText SET `Text` = "掠夺、海岸扫荡和掠夺 [ICON_TradeRoute] 贸易路线的收益+100%。" WHERE `Language` = "zh_Hans_CN" AND `Tag` = "LOC_POLICY_TOTAL_WAR_EXPANSION1_DESCRIPTION";

-- 更新或插入英文记录

UPDATE LocalizedText SET `Text` = "Profit from plundering ,coastal sweeping or [ICON_TradeRoute] +100 %" WHERE `Language` = "en_US" AND `Tag` = "LOC_POLICY_TOTAL_WAR_EXPANSION1_ALT_DESCRIPTION";


UPDATE LocalizedText SET `Text` = "Profit from plundering ,coastal sweeping or [ICON_TradeRoute] +100 %" WHERE `Language` = "en_US" AND `Tag` = "LOC_POLICY_TOTAL_WAR_EXPANSION1_DESCRIPTION";


