include("InstanceManager");
include("LeaderIcon");

include("qd_dealmanager"); -- Already included qd_utils

-- ===========================================================================
--  CONSTANTS
-- ===========================================================================
local MAX_DEAL_ITEM_EDIT_HEIGHT = 300;
local BULK_ADD_AMOUNT = 10;

local AvailableDealItemGroupTypes = {};
AvailableDealItemGroupTypes.EXTRA_LUXURY_RESOURCES = 1;
AvailableDealItemGroupTypes.SINGLE_LUXURY_RESOURCES = 2;
AvailableDealItemGroupTypes.STRATEGIC_RESOURCES = 3;
AvailableDealItemGroupTypes.AGREEMENTS = 4;
AvailableDealItemGroupTypes.GREAT_WORKS = 5;
if g_IsXP2Active then
    AvailableDealItemGroupTypes.FAVOR = table.count(AvailableDealItemGroupTypes) + 1;
end

local m_ItemType = ITEM_TYPE.LUXURY_RESOURCES;
local m_SubType = nil;
local m_SortBy = SORT_BY.EACH;

-- ===========================================================================
--  MEMBERS
-- ===========================================================================
local ms_IconOnlyIM:table = InstanceManager:new("IconOnly", "SelectButton", Controls.IconOnlyContainer);
local ms_IconAndTextIM:table = InstanceManager:new("IconAndText", "SelectButton", Controls.IconAndTextContainer);
local ms_LeftRightListIM:table = InstanceManager:new("LeftRightList", "List", Controls.LeftRightListContainer);
local ms_AIOfferListIM:table = InstanceManager:new("AISaleOfferInstance", "OfferContainer", Controls.AIOffersStack);

local ms_AvailableGroups = {};

local m_UiMyOffers = {};

local m_LocalPlayer = nil;
local m_AIPlayers = {};
local m_AIOffers = {};
local m_LeaderUniqueness = {};

local m_IsCtrlDown = false;

-- ===========================================================================
--  Initialization
-- ===========================================================================
function CreatePanels()
    CreatePlayerAvailablePanel(Controls.MyInventoryStack);
    InitializePullDowns();
end

function CreatePlayerAvailablePanel(rootControl:table)
    ms_AvailableGroups[AvailableDealItemGroupTypes.EXTRA_LUXURY_RESOURCES] = CreateHorizontalGroup(rootControl, "LOC_DIPLOMACY_DEAL_LUXURY_RESOURCES", true);
    ms_AvailableGroups[AvailableDealItemGroupTypes.SINGLE_LUXURY_RESOURCES] = CreateHorizontalGroup(rootControl, "LOC_DIPLOMACY_DEAL_LUXURY_RESOURCES");
    ms_AvailableGroups[AvailableDealItemGroupTypes.STRATEGIC_RESOURCES] = CreateHorizontalGroup(rootControl, "LOC_DIPLOMACY_DEAL_STRATEGIC_RESOURCES");
    if g_IsXP2Active then
        ms_AvailableGroups[AvailableDealItemGroupTypes.FAVOR] = CreateHorizontalGroup(rootControl, "LOC_DIPLOMATIC_FAVOR_NAME");
    end
    ms_AvailableGroups[AvailableDealItemGroupTypes.AGREEMENTS] = CreateHorizontalGroup(rootControl, "LOC_DIPLOMACY_DEAL_AGREEMENTS");
    ms_AvailableGroups[AvailableDealItemGroupTypes.GREAT_WORKS] = CreateHorizontalGroup(rootControl, "LOC_DIPLOMACY_DEAL_GREAT_WORKS");
    rootControl:CalculateSize();
end

function CreateHorizontalGroup(rootStack:table, title:string, isExtra:boolean)
    local iconList = ms_LeftRightListIM:GetInstance(rootStack);
    if (title == nil or title == "") then
        iconList.Title:SetHide(true); -- No title
    elseif isExtra then
        local extraText = Locale.Lookup("LOC_GAMESUMMARY_CATEGORY_EXTRA");
        local titleText = Locale.Lookup(title) .. " [COLOR:Red](" .. Locale.ToUpper(extraText) .. ")[ENDCOLOR]";
        iconList.TitleText:SetText(titleText);
    else
        iconList.TitleText:SetText(Locale.ToUpper(title));
    end
    iconList.List:CalculateSize();
    return iconList;
end

function InitializePullDowns()
    PopulatePullDown(Controls.ItemTypeFilter, ITEM_TYPE_OPTIONS, m_ItemType, function(option)
        if option ~= m_ItemType then
            m_ItemType = option;
            m_SubType = nil;
            local hasSubType = false;
            if m_ItemType == ITEM_TYPE.STRATEGIC_RESOURCES and #STRATEGIC_RESOURCES_OPTIONS > 0 then
                m_SubType = STRATEGIC_RESOURCES_OPTIONS[1][2];
                InitializeSubTypePulldown(STRATEGIC_RESOURCES_OPTIONS);
                hasSubType = true;
            elseif m_ItemType == ITEM_TYPE.GREAT_WORKS and #GREAT_WORK_OPTIONS > 0 then
                m_SubType = GREAT_WORK_OPTIONS[1][2];
                InitializeSubTypePulldown(GREAT_WORK_OPTIONS);
                hasSubType = true;
            end
            Controls.SubTypeFilter:SetHide(not hasSubType);
            UpdateProposedWorkingDeal(false);
        end
    end);
    PopulatePullDown(Controls.SortByFilter, SORT_BY_OPTIONS, m_SortBy, function(option)
        if option ~= m_SortBy then
            m_SortBy = option;
            PopulateAIOfferPanel();
        end
    end);
end

function InitializeSubTypePulldown(options)
    PopulatePullDown(Controls.SubTypeFilter, options, m_SubType, function(option)
        if option ~= m_SubType then
            m_SubType = option;
            UpdateProposedWorkingDeal(false);
        end
    end);
end

-- ===========================================================================
--  Helper functions
-- ===========================================================================
function RemoveDealItems(items:table)
    if items then
        RemoveItemsFromOffer(items);
        UpdateDealPanel();
    end
end

-- ===========================================================================
--  Populating data
-- ===========================================================================
function PopulatePlayerAvailablePanel()
    local availableItemCount = 0;
    availableItemCount = availableItemCount + PopulateAvailableLuxuryResources();
    availableItemCount = availableItemCount + PopulateAvailableStrategicResources();
    if g_IsXP2Active then
        availableItemCount = availableItemCount + PopulateAvailableFavor();
    end
    availableItemCount = availableItemCount + PopulateAvailableAgreements();
    availableItemCount = availableItemCount + PopulateAvailableGreatWorks();
    Controls.MyInventoryStack:CalculateSize();
    Controls.MyInventoryScroll:CalculateSize();
    Controls.NoAvailableItemLabel:SetHide(availableItemCount > 0);
end

function PopulateAvailableLuxuryResources()
    local extraIconList = ms_AvailableGroups[AvailableDealItemGroupTypes.EXTRA_LUXURY_RESOURCES];
    local iconList = ms_AvailableGroups[AvailableDealItemGroupTypes.SINGLE_LUXURY_RESOURCES];
    local availableItemCount = 0;
    availableItemCount = availableItemCount + PopulateAvailableResources("RESOURCECLASS_LUXURY", iconList, extraIconList);
    return availableItemCount;
end

function PopulateAvailableStrategicResources()
    local iconList = ms_AvailableGroups[AvailableDealItemGroupTypes.STRATEGIC_RESOURCES];
    local availableItemCount = 0;
    availableItemCount = availableItemCount + PopulateAvailableResources("RESOURCECLASS_STRATEGIC", iconList);
    return availableItemCount; 
end

function PopulateAvailableResources(className:string, iconList:table, extraIconList:table)
    local availableItemCount = 0;
    local bSeparateExtra = extraIconList ~= nil;
    ms_IconOnlyIM:ReleaseInstanceByParent(iconList.ListStack);
    if bSeparateExtra then
        ms_IconOnlyIM:ReleaseInstanceByParent(extraIconList.ListStack);
    end

    local possibleResources = GetPossibleResources(m_LocalPlayer:GetID(), className);
    for resourceIndex, entry in pairs(possibleResources) do
        local resourceDesc = GameInfo.Resources[entry.ForType];
        local maxAmount = entry.MaxAmount;
        -- Populate extra resource list if there's any.
        if bSeparateExtra and HasExtraResource(m_LocalPlayer:GetID(), resourceIndex, maxAmount) then
            local extraUiIcon = ms_IconOnlyIM:GetInstance(extraIconList.ListStack);
            local extraAmount = entry.MaxAmount - 1;
            -- Update amount to be used by non-extra icon list.
            if entry.MaxAmount > 1 then
                extraAmount = entry.MaxAmount - 1;
                entry.MaxAmount = 1;
            else
                extraAmount = 1;
                entry.MaxAmount = 0;
            end
            SetIconToSize(extraUiIcon.Icon, "ICON_" .. resourceDesc.ResourceType);
            extraUiIcon.AmountText:SetText(tostring(extraAmount));
            extraUiIcon.RemoveButton:SetHide(true);
            extraUiIcon.SelectButton:SetHide(false);
            extraUiIcon.SelectButton:SetDisabled(false);
            extraUiIcon.SelectButton:RegisterCallback(Mouse.eLClick, function() OnClickAvailableResource(m_LocalPlayer, resourceIndex, maxAmount); end);
            local tooltip = Locale.Lookup(resourceDesc.Name);
            if className == "RESOURCECLASS_STRATEGIC" then
                tooltip = tooltip .. "[NEWLINE]" .. Locale.Lookup("LOC_QD_BULK_ADD");
            end
            extraUiIcon.SelectButton:SetToolTipString(tooltip);
            availableItemCount = availableItemCount + 1;
        end
        -- Populate normal resource list.
        if entry.MaxAmount > 0 then
            local uiIcon = ms_IconOnlyIM:GetInstance(iconList.ListStack);
            SetIconToSize(uiIcon.Icon, "ICON_" .. resourceDesc.ResourceType);
            uiIcon.AmountText:SetText(tostring(entry.MaxAmount));
            uiIcon.RemoveButton:SetHide(true);
            uiIcon.SelectButton:SetHide(false);
            uiIcon.SelectButton:SetDisabled(false);
            uiIcon.SelectButton:RegisterCallback(Mouse.eLClick, function() OnClickAvailableResource(m_LocalPlayer, resourceIndex, maxAmount); end);
            local tooltip = Locale.Lookup(resourceDesc.Name);
            if className == "RESOURCECLASS_STRATEGIC" then
                tooltip = tooltip .. "[NEWLINE]" .. Locale.Lookup("LOC_QD_BULK_ADD");
            end
            uiIcon.SelectButton:SetToolTipString(tooltip);
            availableItemCount = availableItemCount + 1;
        end
    end
    iconList.ListStack:CalculateSize();
    if bSeparateExtra then
        extraIconList.ListStack:CalculateSize();
    end
    -- Hide if empty
    iconList.GetTopControl():SetHide(iconList.ListStack:GetSizeX() == 0);
    if bSeparateExtra then
        extraIconList.GetTopControl():SetHide(extraIconList.ListStack:GetSizeX() == 0);
    end
    return availableItemCount;
end

function PopulateAvailableGreatWorks()
    local availableItemCount = 0;
    local iconList = ms_AvailableGroups[AvailableDealItemGroupTypes.GREAT_WORKS];
    ms_IconOnlyIM:ReleaseInstanceByParent(iconList.ListStack);

    local possibleItems = GetPossibleGreatWorks(m_LocalPlayer:GetID());
    for id, entry in pairs(possibleItems) do
        local greatWorkDesc = GameInfo.GreatWorks[entry.ForTypeDescriptionID];
        local uiIcon = ms_IconOnlyIM:GetInstance(iconList.ListStack);
        SetIconToSize(uiIcon.Icon, "ICON_" .. greatWorkDesc.GreatWorkType, 45);
        uiIcon.AmountText:SetText(nil);
        uiIcon.RemoveButton:SetHide(true);
        uiIcon.SelectButton:SetHide(false);
        uiIcon.SelectButton:SetDisabled(false);
        uiIcon.SelectButton:RegisterCallback(Mouse.eLClick, function() OnClickAvailableGreatWork(m_LocalPlayer, id, entry.ForTypeDescriptionID); end);
        uiIcon.SelectButton:LocalizeAndSetToolTip(GreatWorksSupport_GetBasicTooltip(id, false));
        availableItemCount = availableItemCount + 1;
    end
    iconList.ListStack:CalculateSize();
    iconList.GetTopControl():SetHide(iconList.ListStack:GetSizeX() == 0);
    return availableItemCount;
end

function PopulateAvailableFavor()
    if not g_IsXP2Active then return 0; end
    local availableItemCount = 0;
    local iconList = ms_AvailableGroups[AvailableDealItemGroupTypes.FAVOR];
    ms_IconOnlyIM:ReleaseInstanceByParent(iconList.ListStack);
    local favorBalance = m_LocalPlayer:GetFavor();
    if favorBalance > 0 then
        local uiIcon = ms_IconOnlyIM:GetInstance(iconList.ListStack);
        SetIconToSize(uiIcon.Icon, "ICON_YIELD_FAVOR");
        uiIcon.AmountText:SetText(favorBalance);
        uiIcon.RemoveButton:SetHide(true);
        uiIcon.SelectButton:SetHide(false);
        uiIcon.SelectButton:SetDisabled(false);
        uiIcon.SelectButton:RegisterCallback(Mouse.eLClick, function() OnClickAvailableFavor(m_LocalPlayer, favorBalance); end);
        local tooltip = Locale.Lookup("LOC_DIPLOMATIC_FAVOR_NAME") .. "[NEWLINE]" .. Locale.Lookup("LOC_QD_BULK_ADD");
        uiIcon.SelectButton:SetToolTipString(tooltip);
        availableItemCount = availableItemCount + 1;
    end
    iconList.ListStack:CalculateSize();
    iconList.GetTopControl():SetHide(iconList.ListStack:GetSizeX() == 0);
    return availableItemCount;
end

function PopulateAvailableAgreements()
    local availableItemCount = 0;
    local iconList = ms_AvailableGroups[AvailableDealItemGroupTypes.AGREEMENTS];
    ms_IconAndTextIM:ReleaseInstanceByParent(iconList.ListStack);
    -- Only support open borders right now.
    local canPlayerOpenBorder = CanPlayerOpenBorder(m_LocalPlayer:GetID());
    local openBorderActionName = GetDiploActionName(DealAgreementTypes.OPEN_BORDERS);
    if canPlayerOpenBorder and openBorderActionName then
        local openBorderActionTextKey = "";
        if GameInfo.DiplomaticActions[openBorderActionName] then
            openBorderActionTextKey = GameInfo.DiplomaticActions[openBorderActionName].Name;
        end
        local uiIcon = ms_IconAndTextIM:GetInstance(iconList.ListStack);
        SetIconToSize(uiIcon.Icon, "ICON_" .. openBorderActionName, 38);
        uiIcon.AmountText:SetText(nil);
        uiIcon.IconText:LocalizeAndSetText(openBorderActionTextKey);
        uiIcon.ValueText:SetHide(true);
        uiIcon.RemoveButton:SetHide(true);
        uiIcon.SelectButton:SetHide(false);
        uiIcon.SelectButton:SetDisabled(false);
        uiIcon.SelectButton:RegisterCallback(Mouse.eLClick, function() OnClickAvailableAgreement(m_LocalPlayer, DealAgreementTypes.OPEN_BORDERS); end);
        local tooltip = Locale.Lookup("LOC_DIPLOMACY_DEAL_PARAMETER_WITH_TURNS", openBorderActionTextKey, 30);
        uiIcon.SelectButton:SetToolTipString(tooltip);
        availableItemCount = availableItemCount + 1;
    end
    iconList.ListStack:CalculateSize();
    iconList.GetTopControl():SetHide(iconList.ListStack:GetSizeX() == 0);
    return availableItemCount;
end

function PopulatePlayerDealPanel()
    PopulateDealResources();
    -- PopulateDealGreatWorks(player);
    m_UiMyOffers.OfferStack:CalculateSize();
    Controls.MyOfferScroll:CalculateSize();
end

function PopulateDealResources()
    ms_IconOnlyIM:ReleaseInstanceByParent(m_UiMyOffers.OneTimeDealsStack);
    ms_IconOnlyIM:ReleaseInstanceByParent(m_UiMyOffers.For30TurnsDealsStack);
    local offeredItems = GetOfferedItems();
    for dealType, dealItems in pairs(offeredItems) do
        for id, item in pairs(dealItems) do
            local uiIcon = nil;
            if item.Duration == 0 then
                uiIcon = ms_IconOnlyIM:GetInstance(m_UiMyOffers.OneTimeDealsStack);
            else
                uiIcon = ms_IconOnlyIM:GetInstance(m_UiMyOffers.For30TurnsDealsStack);
            end
            SetIconToSize(uiIcon.Icon, GetItemTypeIcon(item));
            if dealType == DealItemTypes.GREATWORK or dealType == DealItemTypes.AGREEMENTS then
                uiIcon.AmountText:SetText(nil);
            else
                uiIcon.AmountText:SetText(item.Amount);
            end
            uiIcon.RemoveButton:SetHide(false);
            uiIcon.RemoveButton:RegisterCallback(Mouse.eLClick, function(void1, void2, self) OnRemoveDealItem(id, dealType, self); end);
            uiIcon.SelectButton:RegisterCallback(Mouse.eRClick, function(void1, void2, self) OnRemoveDealItem(id, dealType, self); end);
            uiIcon.SelectButton:RegisterCallback(Mouse.eLClick, function(void1, void2, self) OnSelectValueDealItem(id, dealType); end);
            uiIcon.SelectButton:SetHide(false);
            uiIcon.SelectButton:SetDisabled(false);
            uiIcon.SelectButton:LocalizeAndSetToolTip(GetItemToolTip(item));
        end
    end
    m_UiMyOffers.OneTimeDealsHeader:SetHide(table.count(m_UiMyOffers.OneTimeDealsStack:GetChildren()) == 0);
    m_UiMyOffers.For30TurnsDealsHeader:SetHide(table.count(m_UiMyOffers.For30TurnsDealsStack:GetChildren()) == 0);
    m_UiMyOffers.OfferStack:CalculateSize();
end

function PopulateAIOfferPanel()
    m_AIOffers = SortOffers(m_AIOffers, m_SortBy, true);
    ms_AIOfferListIM:ResetInstances();
    for _, offer in ipairs(m_AIOffers) do
        if offer.OneTimeGold ~= 0 or offer.MultiTurnGold ~= 0 or offer.HasNonGoldItem then
            local offerControl = ms_AIOfferListIM:GetInstance(Controls.AIOffersStack);
            PopulateAIOffer(offer, offerControl);
        end
    end
    Controls.AIOffersStack:CalculateSize();
    Controls.OfferStackAlphaIn:SetToBeginning();
    Controls.OfferStackAlphaIn:Play();
    Controls.OfferStackSlideIn:SetToBeginning();
    Controls.OfferStackSlideIn:Play();
end

function PopulateAIOffer(offer, offerControl)
    -- Set leader icon.
    local leaderTypeName = PlayerConfigurations[offer.PlayerId]:GetLeaderTypeName();
    local leaderIcon = LeaderIcon:AttachInstance(offerControl.LeaderTargetIcon);
    local leaderIconName = "ICON_" .. leaderTypeName;
    local leaderShowDetails = "[COLOR:Civ6Red]" .. Locale.Lookup("LOC_DIPLO_CHOICE_VIEW_DEAL") .. "[ENDCOLOR]";
    leaderIcon:UpdateIcon(leaderIconName, offer.PlayerId, m_LeaderUniqueness[leaderTypeName], leaderShowDetails);
    leaderIcon:RegisterCallback(Mouse.eLClick, function() OnShowDealDetails(offer.PlayerId); end);
    -- Set gold balance.
    local goldBalance = math.floor(Players[offer.PlayerId]:GetTreasury():GetGoldBalance());
    offerControl.GoldBalance:SetText("[ICON_Gold]" .. tostring(goldBalance));
    -- Set one time gold.
    SetIconToSize(offerControl.OneTimeGold.Icon, "ICON_YIELD_GOLD_5");
    offerControl.OneTimeGold.Icon:SetColor(1,1,1);
    if offer.OneTimeGold == 0 then offerControl.OneTimeGold.Icon:SetColor(0.5, 0.5, 0.5); end
    offerControl.OneTimeGold.AmountText:SetText(offer.OneTimeGold);
    offerControl.OneTimeGold.RemoveButton:SetHide(true);
    offerControl.OneTimeGold.SelectButton:SetHide(false);
    offerControl.OneTimeGold.SelectButton:SetDisabled(offer.OneTimeGold == 0);
    if offer.OneTimeGold > 0 then
        local convertableMTG = math.floor(offer.OneTimeGold / GOLD_RATIO);
        offerControl.OneTimeGold.SelectButton:RegisterCallback(Mouse.eRClick, function() OnUpdateMultiTurnGold(offer.PlayerId, convertableMTG, offerControl); end);
        offerControl.OneTimeGold.SelectButton:LocalizeAndSetToolTip("LOC_QD_CONVERT_ALL");
    end
    -- Set multi turn gold.
    SetIconToSize(offerControl.MultiTurnGold.Icon, "ICON_YIELD_GOLD_5");
    offerControl.MultiTurnGold.Icon:SetColor(1,1,1);
    if offer.MultiTurnGold == 0 then offerControl.MultiTurnGold.Icon:SetColor(0.5, 0.5, 0.5); end
    offerControl.MultiTurnGold.AmountText:SetText(offer.MultiTurnGold);
    offerControl.MultiTurnGold.IconText:LocalizeAndSetText("LOC_DIPLOMACY_DEAL_FOR_TURNS", 30);
    offerControl.MultiTurnGold.ValueText:SetHide(true);
    offerControl.MultiTurnGold.RemoveButton:SetHide(true);
    offerControl.MultiTurnGold.SelectButton:SetDisabled(offer.MultiTurnGold == 0);
    if offer.MultiTurnGold > 0 then
        local convertableMTG = -math.min(math.floor((goldBalance - offer.OneTimeGold) / GOLD_RATIO), offer.MultiTurnGold);
        offerControl.MultiTurnGold.SelectButton:RegisterCallback(Mouse.eRClick, function() OnUpdateMultiTurnGold(offer.PlayerId, convertableMTG, offerControl); end);
        offerControl.MultiTurnGold.SelectButton:LocalizeAndSetToolTip("LOC_QD_CONVERT_ALL");
    end
    -- Hook up multi turn gold change handlers.
    offerControl.IncreaseMTG:SetDisabled(offer.OneTimeGold == 0);
    offerControl.DecreaseMTG:SetDisabled(offer.MultiTurnGold == 0);
    offerControl.IncreaseMTG:RegisterCallback(Mouse.eLClick, function() OnUpdateMultiTurnGold(offer.PlayerId, 1, offerControl); end);
    offerControl.DecreaseMTG:RegisterCallback(Mouse.eLClick, function() OnUpdateMultiTurnGold(offer.PlayerId, -1, offerControl); end);
    -- Set unknown type if needed.
    if offer.HasNonGoldItem then
        SetIconToSize(offerControl.UnknownType.Icon, "ICON_CIVILIZATION_UNKNOWN", 36);
        offerControl.UnknownType.Icon:SetColor(1,1,1);
        offerControl.UnknownType.AmountText:SetText("");
        offerControl.UnknownType.RemoveButton:SetHide(true);
        offerControl.UnknownType.SelectButton:SetHide(false);
        offerControl.UnknownType.SelectButton:SetDisabled(true);
    else
        offerControl.UnknownType.SelectButton:SetHide(true);
    end
    -- Populate offered items.
    ms_IconOnlyIM:ReleaseInstanceByParent(offerControl.OfferedItemsStack);
    for _, item in ipairs(offer.OfferedItems) do
        local uiIcon = ms_IconOnlyIM:GetInstance(offerControl.OfferedItemsStack);
        SetIconToSize(uiIcon.Icon, GetItemTypeIcon(item));
        if item.Type == DealItemTypes.GREATWORK or item.Type == DealItemTypes.AGREEMENTS then
            uiIcon.AmountText:SetText(nil);
        else
            uiIcon.AmountText:SetText(item.Amount);
        end
        uiIcon.RemoveButton:SetHide(true);
        uiIcon.SelectButton:SetHide(false);
        uiIcon.SelectButton:SetDisabled(true);
        uiIcon.SelectButton:LocalizeAndSetToolTip(GetItemToolTip(item));
    end
    offerControl.OfferedItemsStack:CalculateSize();
    -- Set action buttons.
    if offer.HasNonGoldItem then
        -- Hook up show details button.
        offerControl.AcceptDeal:SetHide(true);
        offerControl.DealDetails:SetHide(false);
        offerControl.DealDetails:RegisterCallback(Mouse.eLClick, function() OnShowDealDetails(offer.PlayerId); end);
        offerControl.DealDetails:RegisterCallback(Mouse.eMouseEnter, function() UI.PlaySound("Main_Menu_Mouse_Over"); end);
    else
        -- Hook up accept deal button.
        offerControl.DealDetails:SetHide(true);
        offerControl.AcceptDeal:SetHide(false);
        offerControl.AcceptDeal:RegisterCallback(Mouse.eLClick, function() OnAcceptDeal(offer.PlayerId); end);
        offerControl.AcceptDeal:RegisterCallback(Mouse.eMouseEnter, function() UI.PlaySound("Main_Menu_Mouse_Over"); end);
    end
    -- Set extra info indicator.
    if offer.Equalized == false then
        offerControl.ExtraIndicator:SetHide(false);
        offerControl.ExtraIndicator:LocalizeAndSetToolTip("LOC_QD_ALL_GOLD_HINT");
    else
        offerControl.ExtraIndicator:SetHide(true);
    end
end

function ResetAIOfferPanel()
    m_AIOffers = {};
    PopulateAIOfferPanel();
end

-- ===========================================================================
--  Offer item editing
-- ===========================================================================
function AttachValueEdit(itemId, itemType)
    -- Only resources are editable.
    local item = GetOfferedItems(itemType, itemId);
    if item == nil then return; end

    Controls.ValueEditIconGrid:SetHide(false);
    Controls.ValueAmountEditBoxContainer:SetHide(false);
    Controls.ValueEditHeaderLabel:SetText(Locale.Lookup("LOC_DIPLOMACY_DEAL_HOW_MANY"));
    if item.Duration == 0 then
        Controls.ValueEditValueText:SetHide(true);
    else
        Controls.ValueEditValueText:LocalizeAndSetText("LOC_DIPLOMACY_DEAL_FOR_TURNS", item.Duration);
        Controls.ValueEditValueText:SetHide(false);
    end
    SetIconToSize(Controls.ValueEditIcon, GetItemTypeIcon(item));
    Controls.ValueEditAmountText:SetText(item.Amount);
    Controls.ValueEditAmountText:SetHide(false);
    Controls.ValueAmountEditBox:SetText(item.Amount);
    Controls.ValueEditButton:RegisterCallback(Mouse.eLClick, function() OnValueEditButton(item); end);
    Controls.ValueAmountEditLeftButton:RegisterCallback(Mouse.eLClick, function() OnValueAmountEditDelta(item.MaxAmount, -1); end);
    Controls.ValueAmountEditRightButton:RegisterCallback(Mouse.eLClick, function() OnValueAmountEditDelta(item.MaxAmount, 1); end);
    ResizeValueEditScrollPanel();
    Controls.ValueEditPopupBackground:SetHide(false);
end

function ResizeValueEditScrollPanel()
    -- Resize scroll panel to a maximum height of five agreement options
    Controls.ValueEditStack:CalculateSize();
    if Controls.ValueEditStack:GetSizeY() > MAX_DEAL_ITEM_EDIT_HEIGHT then
        Controls.ValueEditScrollPanel:SetSizeY(MAX_DEAL_ITEM_EDIT_HEIGHT);
    else
        Controls.ValueEditScrollPanel:SetSizeY(Controls.ValueEditStack:GetSizeY());
    end
    Controls.ValueEditScrollPanel:CalculateSize();
end

-- ===========================================================================
--  UI refreshes
-- ===========================================================================
function UpdateDealPanel()
    local hasItems = GetOfferedItemCount() > 0;
    UpdateDealStatus(hasItems);
    PopulatePlayerDealPanel();
    UpdateProposedWorkingDeal(hasItems);
end

function UpdateDealStatus(hasItems:boolean)
    Controls.ItemTypeContainer:SetHide(hasItems);
    Controls.RecommendLabelContainer:SetHide(hasItems);
    m_UiMyOffers.DirectionsBracket:SetHide(hasItems);
    m_UiMyOffers.OfferStack:SetHide(false);
end

function UpdateFetchStatus(isFetching:boolean, hasOffers:boolean)
    Controls.FetchingDealLabel:SetHide(not isFetching);
    Controls.NoAvailableDealLabel:SetHide(isFetching or hasOffers);
end

-- Update AI's offer list.
function UpdateProposedWorkingDeal(hasItems:boolean)
    -- Clear the offer panel before fetching.
    ResetAIOfferPanel();
    UpdateFetchStatus(false, false);
    local localPlayerId = m_LocalPlayer:GetID();
    if hasItems then
        UpdateFetchStatus(true, false);
        LuaEvents.QD_StartAIOfferFetch(localPlayerId, m_AIPlayers, GetOfferedItems());
    else
        -- Populate offer panel with recommended offers if player hasn't provided any items yet.
        local recommendedItems = GetRecommendedItems(localPlayerId, m_ItemType, m_SubType);
        local hasRecommendedItems = false;
        for dealItemType, items in pairs(recommendedItems) do
            if table.count(items) > 0 then
                hasRecommendedItems = true;
                break;
            end
        end
        if hasRecommendedItems then
            UpdateFetchStatus(true, false);
            LuaEvents.QD_StartAIOfferFetch(localPlayerId, m_AIPlayers, recommendedItems);
        end
    end
end
-- ===========================================================================
--  UI event callbacks
-- ===========================================================================
function OnClickAvailableResource(player, resourceIndex, maxAmount)
    local delta = 1;
    if m_IsCtrlDown then
        delta = BULK_ADD_AMOUNT;
    end
    local hasUpdate = AddResourceToOffer(player, resourceIndex, maxAmount, delta);
    if hasUpdate then
        UI.PlaySound("UI_GreatWorks_Put_Down");
        UpdateDealPanel();
    end
end

function OnClickAvailableFavor(player, maxAmount)
    local delta = 1;
    if m_IsCtrlDown then
        delta = BULK_ADD_AMOUNT;
    end
    local hasUpdate = AddFavorToOffer(player, maxAmount, delta);
    if hasUpdate then
        UI.PlaySound("UI_GreatWorks_Put_Down");
        UpdateDealPanel();
    end
end

function OnClickAvailableGreatWork(player, id, descId)
    local hasUpdate = AddGreatWorkToOffer(player, id, descId);
    if hasUpdate then
        UI.PlaySound("UI_GreatWorks_Put_Down");
        UpdateDealPanel();
    end
end

function OnClickAvailableAgreement(player, agreementType)
    local hasUpdate = AddAgreementToOffer(player, agreementType);
    if hasUpdate then
        UI.PlaySound("UI_GreatWorks_Put_Down");
        UpdateDealPanel();
    end
end

function OnSelectValueDealItem(itemId, itemType)
    -- Only resources are editable.
    if itemType ~= DealItemTypes.GREATWORK and itemType ~= DealItemTypes.AGREEMENTS then
        AttachValueEdit(itemId, itemType);
    end
end

function OnRemoveDealItem(itemId, dealType)
    local items = {};
    table.insert(items, { Id = itemId, Type = dealType });
    RemoveDealItems(items);
    UI.PlaySound("UI_GreatWorks_Pick_Up");
end

function OnValueEditButton(item)
    if item then
        local newAmount:number = tonumber(Controls.ValueAmountEditBox:GetText() or 0);
        newAmount = math.min(newAmount, item.MaxAmount);
        newAmount = math.max(newAmount, 1);
        if newAmount ~= item.Amount then
            local delta = newAmount - item.Amount;
            if item.Type == DealItemTypes.RESOURCES then
                AddResourceToOffer(m_LocalPlayer, item.Id, item.MaxAmount, delta);
            elseif item.Type == DealItemTypes.FAVOR then
                AddFavorToOffer(m_LocalPlayer, item.MaxAmount, delta);
            end
            UpdateDealPanel();
        end
    end
    Controls.ValueEditPopupBackground:SetHide(true);
end

function OnValueAmountEditDelta(maxAmount, delta)
    local newAmount:number = tonumber(Controls.ValueAmountEditBox:GetText() or 0) + delta;
    newAmount = math.min(newAmount, maxAmount);
    newAmount = math.max(newAmount, 1);
    Controls.ValueAmountEditBox:SetText(newAmount);
end

function OnAcceptDeal(otherPlayerId)
    if DealManager.AreWorkingDealsEqual(m_LocalPlayer:GetID(), otherPlayerId) then
        LuaEvents.QD_StartAIOfferAccept(m_LocalPlayer:GetID(), otherPlayerId);
    end
end

function OnShowDealDetails(otherPlayerId)
    LuaEvents.QD_RequestDealScreen(otherPlayerId);
end

function OnUpdateMultiTurnGold(otherPlayerId, delta, controlInstance)
    LuaEvents.QD_StartMultiTurnGoldUpdate(m_LocalPlayer:GetID(), otherPlayerId, delta, controlInstance, false);
end

-- ===========================================================================
--  Event handlers
-- ===========================================================================
function OnEndAIOfferAccept(myOfferedItemsInDeal:table)
    if not ContextPtr:IsHidden() then
        -- Update remaining offers.
        if GetOfferedItemCount() == 0 then
            UpdateDealPanel();
        elseif table.count(myOfferedItemsInDeal) == 1 and myOfferedItemsInDeal[1].Type == DealItemTypes.AGREEMENTS then
            -- Only open border was offered, keep it in the offered item to sell it to other AIs.
            UpdateDealPanel();
        else
            RemoveDealItems(myOfferedItemsInDeal);
        end
        PopulatePlayerAvailablePanel();
        UI.PlaySound("Confirm_Bed_Positive");
    end
end

function OnEndAIOfferFetch(aiOffers:table)
    if not ContextPtr:IsHidden() then
        m_AIOffers = aiOffers;
        PopulateAIOfferPanel();
        UpdateFetchStatus(false, #m_AIOffers > 0);
    end
end

function OnEndMultiTurnGoldUpdate(offers, controlInstance)
    if not ContextPtr:IsHidden() then
        if #offers > 0 then
            local offer = offers[1]; -- Only 1 offer exists.
            if offer.OneTimeGold ~= 0 or offer.MultiTurnGold ~= 0 or offer.HasNonGoldItem then
                PopulateAIOffer(offer, controlInstance);
            end
        end
    end
end

function OnShowTab(tabType)
    if tabType == TAB_TYPE.SALE then
        ContextPtr:SetHide(false);
        ContextPtr:ChangeParent(ContextPtr:LookUpControl(TAB_CONTENT_CONTAINER_PATH));

        ms_IconOnlyIM:ResetInstances();
        ms_IconAndTextIM:ResetInstances();
        ms_AIOfferListIM:ResetInstances();

        m_LocalPlayer = Players[Game.GetLocalPlayer()];
        m_AIPlayers = GetAIPlayersToCheck(m_LocalPlayer);
        m_LeaderUniqueness = GetLeaderUniqueness(m_AIPlayers);
        ClearOfferedItems();

        PopulatePlayerAvailablePanel();
        UpdateDealPanel();
    else
        ContextPtr:SetHide(true);
    end
end

function OnInit(isReload)
    if Game.GetLocalPlayer() == -1 then return; end
    m_LocalPlayer = Players[Game.GetLocalPlayer()];

    CreatePanels();
    if isReload and not ContextPtr:IsHidden() then
        OnShowTab(TAB_TYPE.SALE);
    end
end

function OnInputHandler(pInputStruct:table)
    if pInputStruct:GetKey() == Keys.VK_CONTROL then
        m_IsCtrlDown = pInputStruct:GetMessageType() == KeyEvents.KeyDown;
    end
    return false;
end

function QD_Initialize()
    ContextPtr:SetInitHandler(OnInit);
    ContextPtr:SetInputHandler(OnInputHandler, true);
    ContextPtr:SetAutoSize(true);
    ContextPtr:SetHide(true);

    LuaEvents.QD_EndAIOfferAccept.Add(OnEndAIOfferAccept);
    LuaEvents.QD_EndAIOfferFetch.Add(OnEndAIOfferFetch);
    LuaEvents.QD_EndMultiTurnGoldUpdate.Add(OnEndMultiTurnGoldUpdate);
    LuaEvents.QD_PopupShowTab.Add(OnShowTab);

    ContextPtr:BuildInstanceForControl("MyOffers", m_UiMyOffers, Controls.MyOfferScroll);
end

QD_Initialize();