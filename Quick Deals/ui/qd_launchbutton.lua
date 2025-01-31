include("qd_utils");

local MAX_TT_LINES = 3;

local CacheManager = ExposedMembers.QD.CacheManager;

local m_LaunchButtonInstance = {};

function ToggleDealPopup()
    LuaEvents.QD_ToggleDealPopup();
end

function AttachLaunchButton()
    local buttonStack = ContextPtr:LookUpControl("/InGame/LaunchBar/ButtonStack");

    ContextPtr:BuildInstanceForControl("LaunchBarItem", m_LaunchButtonInstance, buttonStack);
    m_LaunchButtonInstance.LaunchItemButton:RegisterCallback(Mouse.eLClick, ToggleDealPopup);
    m_LaunchButtonInstance.LaunchItemIcon:SetTexture(IconManager:FindIconAtlas("ICON_NOTIFICATION_QUICK_DEAL", 36));

    ContextPtr:BuildInstanceForControl("LaunchBarPinInstance", {}, buttonStack);

    -- Resize.
    buttonStack:CalculateSize();

    local backing = ContextPtr:LookUpControl("/InGame/LaunchBar/LaunchBacking");
    backing:SetSizeX(buttonStack:GetSizeX() + 116);

    local backingTile = ContextPtr:LookUpControl("/InGame/LaunchBar/LaunchBackingTile");
    backingTile:SetSizeX(buttonStack:GetSizeX() - 20);

    LuaEvents.LaunchBar_Resize(buttonStack:GetSizeX());
end

function CheckAvailableDeals()
    local playerId = Game.GetLocalPlayer();
    if playerId == -1 then return; end

    local deals = {};
    local player = Players[playerId];
    local cachedSellableDeals = CacheManager.GetCachedDeals(true) or {};
    local cacheBuyableDeals = CacheManager.GetCachedDeals(false) or {};
    local updatedSellableDeals = {};
    local updatedBuyableDeals = {};

    local hasUpdate = false;
    local allSellableTTLines = {};
    local allBuyableTTLines = {};
    local allPlayers = PlayerManager.GetAliveMajors();
    for _, otherPlayer in ipairs(allPlayers) do
        local otherPlayerId = otherPlayer:GetID();
        if player:GetDiplomacy():HasMet(otherPlayerId) and otherPlayer:IsAI() then
            -- Check sellable deals.
            local oldSellableDeals = cachedSellableDeals[otherPlayerId] or {};
            local newSellableDeals = GetAvailableDeals(playerId, otherPlayerId);
            updatedSellableDeals[otherPlayerId] = newSellableDeals;
            local diffSellableDeals = GetDiffDeals(oldSellableDeals, newSellableDeals);
            local sellableTTLines = GetDealsToolTips(otherPlayerId, diffSellableDeals, true);
            for _, line in ipairs(sellableTTLines) do
                table.insert(allSellableTTLines, line);
            end
            -- Check buyable deals.
            local oldBuyableDeals = cacheBuyableDeals[otherPlayerId] or {};
            local newBuyableDeals = GetAvailableDeals(otherPlayerId, playerId);
            updatedBuyableDeals[otherPlayerId] = newBuyableDeals;
            local diffbuyableDeals = GetDiffDeals(oldBuyableDeals, newBuyableDeals);
            local buyableTTLines = GetDealsToolTips(otherPlayerId, diffbuyableDeals, false);
            for _, line in ipairs(buyableTTLines) do
                table.insert(allBuyableTTLines, line);
            end
        end
    end
    CacheManager.SetCachedDeals(updatedSellableDeals, true);
    CacheManager.SetCachedDeals(updatedBuyableDeals, false);

    -- UI updates.
    if #allSellableTTLines > 0 or #allBuyableTTLines > 0 then
        local ttStr = "";
        if #allSellableTTLines > 0 then
            local sellableTTStr = GetToolTipStrFromLines(allSellableTTLines);
            ttStr = sellableTTStr;
        end
        if #allBuyableTTLines > 0 then
            if ttStr ~= "" then
                ttStr = ttStr .. "[NEWLINE]";
            end
            local buyableTTStr = GetToolTipStrFromLines(allBuyableTTLines);
            ttStr = ttStr .. buyableTTStr;
        end
        -- Only send notification if user wanted to.
        if not IsNotificationOptedOut() then
            NotificationManager.SendNotification(playerId, QD_NOTIFICATION_HASH, Locale.Lookup("LOC_QD_NEW_DEALS_AVAILABLE"), ttStr);
        end

        -- Show info button next to launch button.
        if m_LaunchButtonInstance ~= nil and m_LaunchButtonInstance.AlertIndicator ~= nil then
            m_LaunchButtonInstance.AlertIndicator:SetHide(false);
        end
    end
end

function GetAvailableDeals(fromPlayerId, toPlayerId)
    local availableDeals = {};
    availableDeals[DealItemTypes.RESOURCES] = {};
    local deal = DealManager.GetWorkingDeal(DealDirection.OUTGOING, fromPlayerId, toPlayerId);
    -- Get possible resources.
    local possibleResources = DealManager.GetPossibleDealItems(fromPlayerId, toPlayerId, DealItemTypes.RESOURCES, deal);
    if possibleResources ~= nil then
        for i, entry in ipairs(possibleResources) do
            local index = entry.ForType;
            local resourceDesc = GameInfo.Resources[index];
            if resourceDesc ~= nil then
                local toPlayerNeededAmount = ResourceAmountNeeded(toPlayerId, index, false);
                if resourceDesc.ResourceClassType == "RESOURCECLASS_LUXURY"
                    or (not g_IsXP2Active and resourceDesc.ResourceClassType == "RESOURCECLASS_STRATEGIC") then
                        -- Tradable luxury resource means player has extra resource copy but other player doesn't have it.
                        if toPlayerNeededAmount > 0 and HasExtraResource(fromPlayerId, index, entry.MaxAmount) then
                            availableDeals[DealItemTypes.RESOURCES][index] = true;
                        end
                elseif resourceDesc.ResourceClassType == "RESOURCECLASS_STRATEGIC" then
                    if Game.GetLocalPlayer() == fromPlayerId then
                        if toPlayerNeededAmount > 0 then
                            availableDeals[DealItemTypes.RESOURCES][index] = true;
                        end
                    elseif ResourceAmountNeeded(toPlayerId, index, true) > 0 and entry.MaxAmount >= GetStrategicResourceThreshold(index) then
                        availableDeals[DealItemTypes.RESOURCES][index] = true;
                    end
                end
            end
        end
    end
    return availableDeals;
end

function GetDiffDeals(oldDeals, newDeals)
    local diffDeals = {};
    for type, items in pairs(newDeals) do
        diffDeals[type] = {};
        if oldDeals[type] == nil then
            diffDeals[type] = items;
        else
            for index in pairs(items) do
                if oldDeals[type][index] == nil then
                    diffDeals[type][index] = true;
                end
            end
        end
    end
    return diffDeals;
end

function GetDealsToolTips(otherPlayerId, deals, isSell)
    local toolTipLines = {};
    local youText = Locale.Lookup("LOC_HUD_CITY_YOU");
    local leaderName = Locale.Lookup(PlayerConfigurations[otherPlayerId]:GetLeaderName());
    for type, items in pairs(deals) do
        if type == DealItemTypes.RESOURCES then
            for index in pairs(items) do
                local resourceDesc = GameInfo.Resources[index];
                local resourceStr = "[ICON_".. resourceDesc.ResourceType.."]" .. Locale.Lookup(resourceDesc.Name);
                if isSell then
                    table.insert(toolTipLines, youText .. " [ICON_GoingTo] " .. leaderName .. " " .. resourceStr);
                else
                    table.insert(toolTipLines, leaderName .. " [ICON_GoingTo] " .. youText .. " " .. resourceStr);
                end
            end
        end
    end
    return toolTipLines;
end

function GetToolTipStrFromLines(lines)
    local numOfLines = math.min(MAX_TT_LINES, #lines);
    local tempLines = {};
    for i = 1, numOfLines do
        table.insert(tempLines, lines[i]);
    end
    local toolTipStr = table.concat(tempLines, "[NEWLINE]");
    if #lines > MAX_TT_LINES then
        toolTipStr = toolTipStr .. "[NEWLINE]...";
    end
    return toolTipStr;
end

function OnLoadGameViewStateDone()
    AttachLaunchButton();
    CheckAvailableDeals();
end

function OnDealPopupOpened()
    if m_LaunchButtonInstance ~= nil and m_LaunchButtonInstance.AlertIndicator ~= nil then
        m_LaunchButtonInstance.AlertIndicator:SetHide(true);
    end
end

function OnPlayerTurnActivated(playerId:number, isFirstTimeThisTurn:boolean)
    if Game.GetLocalPlayer() == playerId and isFirstTimeThisTurn and not GameConfiguration.IsAnyMultiplayer() then
        CheckAvailableDeals();
    end
end

function QD_Initialize()
    Events.LoadGameViewStateDone.Add(OnLoadGameViewStateDone);
	Events.PlayerTurnActivated.Add(OnPlayerTurnActivated);

    LuaEvents.QDDealPopup_Opened.Add(OnDealPopupOpened);
end

QD_Initialize();