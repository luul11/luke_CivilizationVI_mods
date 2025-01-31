include("InstanceManager");
include("LeaderIcon");
include("qd_utils");

-- ===========================================================================
--  CONSTANTS
-- ===========================================================================

-- ===========================================================================
--  MEMBERS
-- ===========================================================================
local ms_IconOnlyIM:table = InstanceManager:new("IconOnly", "SelectButton", Controls.IconOnlyContainer);
local ms_IconAndTextIM:table = InstanceManager:new("IconAndText", "SelectButton", Controls.IconAndTextContainer);
local ms_AIOfferListIM:table = InstanceManager:new("AIPurchaseOfferRowInstance", "OfferRowContainer", Controls.AIOffersStack);

local m_ItemType = ITEM_TYPE.LUXURY_RESOURCES;
local m_SubType = nil;
local m_SortBy = SORT_BY.EACH;

local m_LocalPlayer = nil;
local m_AIPlayers = {};
local m_AIOffers = {};
local m_LeaderUniqueness = {};

-- ===========================================================================
--  Initialization
-- ===========================================================================
function CreatePanels()
    InitializePullDowns();
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
            UpdateAIDeals();
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
            UpdateAIDeals();
        end
    end);
end

-- ===========================================================================
--  Populating data
-- ===========================================================================
function PopulateAIOfferPanel()
    m_AIOffers = SortOffers(m_AIOffers, m_SortBy, false);
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
        local goldBalance = math.floor(m_LocalPlayer:GetTreasury():GetGoldBalance());
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
        if item.Type == DealItemTypes.GREATWORK then
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
--  UI refreshes
-- ===========================================================================
function UpdateAIDeals()
    ResetAIOfferPanel();
    UpdateFetchStatus(true, false);
    LuaEvents.QD_StartAIOfferFetch(m_LocalPlayer:GetID(), m_AIPlayers, {}, m_ItemType, m_SubType);
end

function UpdateFetchStatus(isFetching:boolean, hasOffers:boolean)
    Controls.FetchingDealLabel:SetHide(not isFetching);
    Controls.NoAvailableDealLabel:SetHide(isFetching or hasOffers);
end

-- ===========================================================================
--  UI event callbacks
-- ===========================================================================
function OnAcceptDeal(otherPlayerId)
    if DealManager.AreWorkingDealsEqual(m_LocalPlayer:GetID(), otherPlayerId) then
        LuaEvents.QD_StartAIOfferAccept(m_LocalPlayer:GetID(), otherPlayerId);
    end
end

function OnShowDealDetails(otherPlayerId)
    LuaEvents.QD_RequestDealScreen(otherPlayerId);
end

function OnUpdateMultiTurnGold(otherPlayerId, delta, controlInstance)
    LuaEvents.QD_StartMultiTurnGoldUpdate(m_LocalPlayer:GetID(), otherPlayerId, delta, controlInstance, true);
end

-- ===========================================================================
--  Event handlers
-- ===========================================================================
function OnEndAIOfferAccept(myOfferedItemsInDeal:table)
    if not ContextPtr:IsHidden() then
        UpdateAIDeals();
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
    if tabType == TAB_TYPE.PURCHASE then
        ContextPtr:SetHide(false);
        ContextPtr:ChangeParent(ContextPtr:LookUpControl(TAB_CONTENT_CONTAINER_PATH));

        ms_IconOnlyIM:ResetInstances();
        ms_IconAndTextIM:ResetInstances();
        ms_AIOfferListIM:ResetInstances();

        m_LocalPlayer = Players[Game.GetLocalPlayer()];
        m_AIPlayers = GetAIPlayersToCheck(m_LocalPlayer);
        m_LeaderUniqueness = GetLeaderUniqueness(m_AIPlayers);
        UpdateAIDeals();
    else
        ContextPtr:SetHide(true);
    end
end

function OnInit(isReload)
    if Game.GetLocalPlayer() == -1 then return; end
    m_LocalPlayer = Players[Game.GetLocalPlayer()];

    CreatePanels();
    if isReload and not ContextPtr:IsHidden() then
        OnShowTab(TAB_TYPE.PURCHASE);
    end
end

function QD_Initialize()
    ContextPtr:SetInitHandler(OnInit);
    ContextPtr:SetAutoSize(true);
    ContextPtr:SetHide(true);

    LuaEvents.QD_EndAIOfferAccept.Add(OnEndAIOfferAccept);
    LuaEvents.QD_EndAIOfferFetch.Add(OnEndAIOfferFetch);
    LuaEvents.QD_EndMultiTurnGoldUpdate.Add(OnEndMultiTurnGoldUpdate);
    LuaEvents.QD_PopupShowTab.Add(OnShowTab);
end

QD_Initialize();