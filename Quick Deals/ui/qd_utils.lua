include("GreatWorksSupport");

g_IsXP1Active = Modding.IsModActive("1B28771A-C749-434B-9053-D1380C553DE9");
g_IsXP2Active = Modding.IsModActive("4873eb62-8ccc-4574-b784-dda455e74e68");

EARLY_STRATEGIC_RESOURCES_THRESHOLD = 40;
LATE_STRATEGIC_RESOURCES_THRESHOLD = 22;
URANIUM_STRATEGIC_RESOURCES_THRESHOLD = 62;
DIPLOMATIC_FAVOR_THRESHOLD = 20;

GOLD_RATIO = 21; -- 21 OTG to 1 MTG.

QD_NOTIFICATION_HASH = GameInfo.Types["NOTIFICATION_QUICK_DEAL"].Hash;

TAB_TYPE = {
    SALE = "TAB_SALE",
    PURCHASE = "TAB_PURCHASE",
    EXCHANGE = "TAB_EXCHANGE",
};
TAB_CONTENT_CONTAINER_PATH = "/InGame/qd_dealpopup/TabContentContainer";

ITEM_TYPE = {
    LUXURY_RESOURCES = 1,
    STRATEGIC_RESOURCES = 2,
    GREAT_WORKS = 3,
};
if g_IsXP2Active then
    ITEM_TYPE.FAVOR = table.count(ITEM_TYPE) + 1;
end
ITEM_TYPE_OPTIONS = {
    {"LOC_REPORTS_LUXURY_RESOURCES", ITEM_TYPE.LUXURY_RESOURCES},
    {"LOC_REPORTS_STRATEGIC_RESOURCES", ITEM_TYPE.STRATEGIC_RESOURCES},
    {"LOC_GREAT_WORKS", ITEM_TYPE.GREAT_WORKS},
};
if g_IsXP2Active then
    table.insert(ITEM_TYPE_OPTIONS, {"LOC_DIPLOMATIC_FAVOR_NAME", ITEM_TYPE.FAVOR});
end

SORT_BY = {
    EACH = 1,
    TOTAL = 2,
};
SORT_BY_OPTIONS = {
    {"LOC_QD_EACH", SORT_BY.EACH},
    {"LOC_HUD_CITY_TOTAL", SORT_BY.TOTAL},
};

GOLD_TYPE = {
    ONE_TIME = 1,
    MULTI_TURN = 2,
};
GOLD_TYPE_OPTIONS = {
    {"LOC_TOP_PANEL_GOLD", GOLD_TYPE.ONE_TIME},
    {"LOC_TOP_PANEL_GOLD_YIELD", GOLD_TYPE.MULTI_TURN},
};

-- Static initialization for strategic resources sub types.
STRATEGIC_RESOURCES_OPTIONS = {};
for row in GameInfo.Resources() do
    if row.ResourceClassType == "RESOURCECLASS_STRATEGIC" then
        local indexToInsert = #STRATEGIC_RESOURCES_OPTIONS + 1;
        for i, item in ipairs(STRATEGIC_RESOURCES_OPTIONS) do
            if row.RevealedEra < GameInfo.Resources[item[2]].RevealedEra then
                indexToInsert = i;
                break;
            end
        end
        table.insert(STRATEGIC_RESOURCES_OPTIONS, indexToInsert, { row.Name, row.Index });
    end
end

-- Static initialization for great work sub types.
GREAT_WORK_OPTIONS = {};
for row in GameInfo.GreatWorkObjectTypes() do
    table.insert(GREAT_WORK_OPTIONS, { row.Name, row.Index });
end

DIPLOMATIC_FAVOR_INDEX = 1; -- item index for diplomatic favor.

OPT_OUT_NOTIFICATION_KEY = "QD_OPT_OUT_NOTIFICATION";

-- ===========================================================================
--  Helper functions
-- ===========================================================================
function IsNotificationOptedOut()
    if GameConfiguration.IsAnyMultiplayer() then return true; end
    return GameConfiguration.GetValue(OPT_OUT_NOTIFICATION_KEY) == true;
end

function ToggleNotificationOptedOut()
    if GameConfiguration.IsAnyMultiplayer() then return; end
    GameConfiguration.SetValue(OPT_OUT_NOTIFICATION_KEY, not IsNotificationOptedOut());
end

function SetIconToSize(iconControl, iconName, iconSize)
    if iconSize == nil then
        iconSize = 50;
    end
    local x, y, szIconName, iconSize = IconManager:FindIconAtlasNearestSize(iconName, iconSize, true);
    iconControl:SetTexture(x, y, szIconName);
    iconControl:SetSizeVal(iconSize, iconSize);
end

function GetItemTypeIcon(item)
    if item.Type == DealItemTypes.RESOURCES then
        return "ICON_" .. GameInfo.Resources[item.Id].ResourceType;
    elseif item.Type == DealItemTypes.FAVOR then
        return "ICON_YIELD_FAVOR";
    elseif item.Type == DealItemTypes.GREATWORK then
        return "ICON_" .. GameInfo.GreatWorks[item.DescId].GreatWorkType, 45;
    elseif item.Type == DealItemTypes.AGREEMENTS then
        return "ICON_" .. GetDiploActionName(item.Id), 38;
    end
    return "ICON_CIVILIZATION_UNKNOWN";
end

function GetItemToolTip(item)
    if item.Type == DealItemTypes.RESOURCES then
        return GameInfo.Resources[item.Id].Name;
    elseif item.Type == DealItemTypes.FAVOR then
        return "LOC_DIPLOMATIC_FAVOR_NAME";
    elseif item.Type == DealItemTypes.GREATWORK then
        return GreatWorksSupport_GetBasicTooltip(item.Id, false);
    elseif item.Type == DealItemTypes.AGREEMENTS then
        local actionName = GetDiploActionName(item.Id);
        if actionName and GameInfo.DiplomaticActions[actionName] then
            local actionTextKey = GameInfo.DiplomaticActions[actionName].Name;
            return Locale.Lookup("LOC_DIPLOMACY_DEAL_PARAMETER_WITH_TURNS", actionTextKey, 30);
        end
    end
    return nil;
end

-- Get AI player ids to check.
function GetAIPlayersToCheck(player)
    local playerIds = {};
    local allPlayers = PlayerManager.GetAliveMajors();
    local playerDiplomacy = player:GetDiplomacy();
    for _, otherPlayer in ipairs(allPlayers) do
        local otherPlayerId = otherPlayer:GetID();
        if playerDiplomacy:HasMet(otherPlayerId) and otherPlayer:IsAI() and not playerDiplomacy:IsAtWarWith(otherPlayerId) then
            table.insert(playerIds, otherPlayerId);
        end
    end
    return playerIds;
end

function GetLeaderUniqueness(aiPlayers)
    local isUniqueLeader = {};
    for _, aiPlayerId in ipairs(aiPlayers) do
        local leaderName:string = PlayerConfigurations[aiPlayerId]:GetLeaderTypeName();
        if isUniqueLeader[leaderName] == nil then
            isUniqueLeader[leaderName] = true;
        else
            isUniqueLeader[leaderName] = false;
        end
    end
    return isUniqueLeader;
end

function SortOffers(unsortedOffers, sortType, descending:boolean)
    if sortType == SORT_BY.TOTAL then
        table.sort(unsortedOffers, function(a, b)
            if descending then
                return a.Total > b.Total;
            else
                return a.Total < b.Total;
            end
        end);
    elseif sortType == SORT_BY.EACH then
        table.sort(unsortedOffers, function(a, b)
            -- Sum of offered items amount.
            local aCount = 0;
            for _, item in ipairs(a.OfferedItems) do
                aCount = aCount + item.Amount;
            end
            local bCount = 0;
            for _, item in ipairs(b.OfferedItems) do
                bCount = bCount + item.Amount;
            end
            if descending then
                return (a.Total / aCount) > (b.Total / bCount);
            else
                return (a.Total / aCount) < (b.Total / bCount);
            end
        end);
    end
    return unsortedOffers;
end

function CloseAllDiplomacySessions(sessionIdToSkip)
    local localPlayerId = Game.GetLocalPlayer();
    if localPlayerId == -1 then return; end

    local localPlayer = Players[localPlayerId];
    local otherPlayers = GetAIPlayersToCheck(localPlayer);
    for _, otherPlayerId in ipairs(otherPlayers) do
        local sessionId = DiplomacyManager.FindOpenSessionID(localPlayerId, otherPlayerId);
        if sessionId ~= nil and sessionId ~= sessionIdToSkip then
            DiplomacyManager.CloseSession(sessionId);
        end
    end
end

function GetRecommendedItems(playerId:number, itemType, subType)
    local items = {};
    items[DealItemTypes.RESOURCES] = {};
    items[DealItemTypes.GREATWORK] = {};
    if g_IsXP2Active then
        items[DealItemTypes.FAVOR] = {};
    end
    if itemType == ITEM_TYPE.LUXURY_RESOURCES then
        local possibleResources = GetPossibleResources(playerId, "RESOURCECLASS_LUXURY");
        for resourceIndex, entry in pairs(possibleResources) do
            if HasExtraResource(playerId, resourceIndex, entry.MaxAmount) then
                items[DealItemTypes.RESOURCES][resourceIndex] = {
                    Id = resourceIndex,
                    Type = DealItemTypes.RESOURCES,
                    Amount = 1,
                    MaxAmount = entry.MaxAmount,
                    Duration = entry.Duration
                };
            end
        end
    elseif itemType == ITEM_TYPE.STRATEGIC_RESOURCES then
        local possibleResources = GetPossibleResources(playerId, "RESOURCECLASS_STRATEGIC");
        for resourceIndex, entry in pairs(possibleResources) do
            if resourceIndex == subType then
                local maxAmount = entry.MaxAmount;
                if not g_IsXP2Active then
                    maxAmount = math.min(1, maxAmount);
                end
                if maxAmount > 0 then
                    items[DealItemTypes.RESOURCES][resourceIndex] = {
                        Id = resourceIndex,
                        Type = DealItemTypes.RESOURCES,
                        Amount = maxAmount,
                        MaxAmount = maxAmount,
                        Duration = entry.Duration
                    };
                end
            end
        end
    elseif g_IsXP2Active and itemType == ITEM_TYPE.FAVOR then
        local player = Players[playerId];
        local favorBalance = player:GetFavor();
        if player:IsHuman() and favorBalance > 0 then
            items[DealItemTypes.FAVOR][DIPLOMATIC_FAVOR_INDEX] = {
                Id = DIPLOMATIC_FAVOR_INDEX,
                Type = DealItemTypes.FAVOR,
                Amount = favorBalance,
                MaxAmount = favorBalance,
                Duration = 0
            };
        end
    elseif itemType == ITEM_TYPE.GREAT_WORKS then
        local possibleItems = GetPossibleGreatWorks(playerId);
        for id, entry in pairs(possibleItems) do
            local objectType = GameInfo.GreatWorks[entry.ForTypeDescriptionID].GreatWorkObjectType;
            if objectType == GameInfo.GreatWorkObjectTypes[subType].GreatWorkObjectType then
                items[DealItemTypes.GREATWORK][id] = {
                    Id = id,
                    DescId = entry.ForTypeDescriptionID,
                    Type = DealItemTypes.GREATWORK,
                    Amount = 1,
                    MaxAmount = 1,
                    Duration = 0
                };
                -- Only add one item at a time.
                break;
            end
        end
    end
    return items;
end

-- Check if the given player has extra copy of the given resource.
function HasExtraResource(playerId:number, resourceIndex:number, tradableAmount:number)
    local player = Players[playerId];
    if Game.GetLocalPlayer() == playerId then
        return tradableAmount > 0 and player:GetResources():GetResourceAmount(resourceIndex) > 1;
    else
        return tradableAmount > 1;
    end
end

-- Get the given player's needed amount for the given resource item.
function ResourceAmountNeeded(playerId, resourceIndex, limitToCap:boolean)
    local player = Players[playerId];
    local playerResources = player:GetResources();

    local resourceDesc = GameInfo.Resources[resourceIndex];
    if resourceDesc == nil then return 0; end

    local resourceType = resourceDesc.ResourceType;
    if g_IsXP2Active and resourceDesc.ResourceClassType == "RESOURCECLASS_STRATEGIC" then
        local stockpileAmount:number = playerResources:GetResourceAmount(resourceType);
        if limitToCap then
            local stockpileCap:number = playerResources:GetResourceStockpileCap(resourceType);
            return stockpileCap - stockpileAmount;
        else
            return math.max(GetStrategicResourceThreshold(resourceIndex) - stockpileAmount, 0);
        end
    elseif not playerResources:HasResource(resourceType) then
        return 1;
    else
        return 0;
    end
end

function GetStrategicResourceThreshold(resourceIndex)
    local resourceDesc = GameInfo.Resources[resourceIndex];
    if resourceDesc == nil then return 0; end
    if resourceDesc.ResourceType == "RESOURCE_URANIUM" then
        return URANIUM_STRATEGIC_RESOURCES_THRESHOLD;
    elseif resourceDesc.RevealedEra >= 5 then -- starting from ERA_INDUSTRIAL.
        return LATE_STRATEGIC_RESOURCES_THRESHOLD;
    else
        return EARLY_STRATEGIC_RESOURCES_THRESHOLD;
    end
end

-- Get given player's possible resources that can trade with all AIs.
function GetPossibleResources(playerId:number, className:string)
    local resourceMap = {};
    -- Getting all possible resources by checking possible deals with other met players.
    -- In fact, only need to check with one other player for possible resources to trade.
    local aiList = GetAIPlayersToCheck(Players[playerId]);
    for _, otherPlayerId in ipairs(aiList) do
        local deal = DealManager.GetWorkingDeal(DealDirection.OUTGOING, playerId, otherPlayerId);
        local possibleResources = DealManager.GetPossibleDealItems(playerId, otherPlayerId, DealItemTypes.RESOURCES, deal);
        if possibleResources ~= nil then
            for i, entry in ipairs(possibleResources) do
                if entry.MaxAmount > 0 then
                    local resourceDesc = GameInfo.Resources[entry.ForType];
                    if resourceDesc ~= nil and resourceDesc.ResourceClassType == className then
                        resourceMap[entry.ForType] = entry;
                    end
                end
            end
        end
    end
    return resourceMap;
end

function GetPossibleGreatWorks(playerId:number)
    local itemMap = {};
    -- Getting all possible great works by checking possible deals with other met players.
    -- In fact, only need to check with one other player for possible resources to trade.
    local aiList = GetAIPlayersToCheck(Players[playerId]);
    for _, otherPlayerId in ipairs(aiList) do
        local deal = DealManager.GetWorkingDeal(DealDirection.OUTGOING, playerId, otherPlayerId);
        local possibleItems = DealManager.GetPossibleDealItems(playerId, otherPlayerId, DealItemTypes.GREATWORK, deal);
        if possibleItems ~= nil then
            for i, entry in ipairs(possibleItems) do
                itemMap[entry.ForType] = entry;
            end
        end
    end
    return itemMap;
end

-- Return gold details.
-- {
--    OneTimeGold = 1,
--    MultiTurnGold = 2,
--    MaxOneTimeGold = 10,
--    MaxMultiTurnGold = 5,
--    HasNonGoldItem = false
-- }
function GetPlayerGoldInDeal(deal, goldPlayerId)
    local goldDetails = {};
    goldDetails.HasNonGoldItem = false;
    for dealItem in deal:Items() do
        if dealItem:GetFromPlayerID() == goldPlayerId then
            if dealItem:GetType() == DealItemTypes.GOLD then
                if dealItem:GetDuration() == 0 then
                    goldDetails.OneTimeGold = dealItem:GetAmount();
                    goldDetails.MaxOneTimeGold = dealItem:GetMaxAmount();
                else
                    goldDetails.MultiTurnGold = dealItem:GetAmount();
                    goldDetails.MaxMultiTurnGold = dealItem:GetMaxAmount();
                end
            else
                goldDetails.HasNonGoldItem = true;
            end
        end
    end
    if goldDetails.OneTimeGold == nil then
        local dealItem = deal:AddItemOfType(DealItemTypes.GOLD, goldPlayerId);
        if dealItem ~= nil then
            dealItem:SetDuration(0);
            goldDetails.OneTimeGold = 0;
            goldDetails.MaxOneTimeGold = dealItem:GetMaxAmount();
            deal:RemoveItemByID(dealItem:GetID());
        end
    end
    if goldDetails.MultiTurnGold == nil then
        local dealItem = deal:AddItemOfType(DealItemTypes.GOLD, goldPlayerId);
        if dealItem ~= nil then
            dealItem:SetDuration(30);
            goldDetails.MultiTurnGold = 0;
            goldDetails.MaxMultiTurnGold = dealItem:GetMaxAmount();
            deal:RemoveItemByID(dealItem:GetID());
        end
    end
    goldDetails.OneTimeGold = goldDetails.OneTimeGold or 0;
    goldDetails.MaxOneTimeGold = goldDetails.MaxOneTimeGold or 0;
    goldDetails.MultiTurnGold = goldDetails.MultiTurnGold or 0;
    goldDetails.MaxMultiTurnGold = goldDetails.MaxMultiTurnGold or 0;
    return goldDetails;
end

function CanPlayerOpenBorder(playerId:number)
    local openBorderActionDesc = GameInfo.DiplomaticActions["DIPLOACTION_OPEN_BORDERS"];
    if openBorderActionDesc ~= nil then
        local openBorderPrereqCivic = openBorderActionDesc.InitiatorPrereqCivic;
        if openBorderPrereqCivic ~= nil then
            local player = Players[playerId];
            local civicId = GameInfo.Civics[openBorderPrereqCivic].Index;
            return player:GetCulture():HasCivic(civicId);
        end
    end
    return false;
end

function GetDiploActionName(actionHash)
    for row in GameInfo.DiplomaticActions() do
        local type = row.DiplomaticActionType;
        if GameInfo.Types[type] and GameInfo.Types[type].Hash == actionHash then
            return type;
        end
    end
    return nil;
end

function PopulatePullDown(control, values, selectedValue, selectionHandler)
	control:ClearEntries();
	for i, v in ipairs(values) do
		local instance = {};
		control:BuildEntry("InstanceOne", instance);
		instance.Button:SetVoid1(i);
        instance.Button:LocalizeAndSetText(v[1]);
		if(v[2] == selectedValue) then
			local button = control:GetButton();
            button:LocalizeAndSetText(v[1]);
		end
	end
	control:CalculateInternals();
	if selectionHandler then
		control:GetButton():RegisterCallback(Mouse.eMouseEnter, function()
            UI.PlaySound("Main_Menu_Mouse_Over");
		end);
		control:RegisterSelectionCallback(
			function(voidValue1, voidValue2, control)
				local option = values[voidValue1];
				local button = control:GetButton();
                button:LocalizeAndSetText(option[1]);
				selectionHandler(option[2]);
			end
		);
	end
end

function table_print(tt, indent, done)
    done = done or {}
    indent = indent or 0
    if type(tt) == "table" then
        local sb = {}
        for key, value in pairs(tt) do
            table.insert(sb, string.rep(" ", indent)) -- indent it
            if type(value) == "table" and not done[value] then
                done[value] = true
                table.insert(sb, key .. " = {\n");
                table.insert(sb, table_print(value, indent + 2, done))
                table.insert(sb, string.rep(" ", indent)) -- indent it
                table.insert(sb, "}\n");
            elseif "number" == type(key) then
                table.insert(sb, string.format("\"%s\"\n", tostring(value)))
            else
                table.insert(sb, string.format("%s = \"%s\"\n", tostring(key), tostring(value)))
            end
        end
        return table.concat(sb)
    else
        return tt .. "\n"
    end
end

function to_string(tbl)
    if "nil" == type(tbl) then
        return tostring(nil)
    elseif "table" == type(tbl) then
        return table_print(tbl)
    elseif "string" == type(tbl) then
        return tbl
    else
        return tostring(tbl)
    end
end