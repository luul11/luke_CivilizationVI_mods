include("InstanceManager");
include("LeaderIcon");
include("qd_utils");

-- ===========================================================================
--  CONSTANTS
-- ===========================================================================
local MAX_DEAL_ITEM_EDIT_HEIGHT = 300;

-- ===========================================================================
--  MEMBERS
-- ===========================================================================
local ms_IconOnlyIM:table = InstanceManager:new("IconOnly", "SelectButton", Controls.IconOnlyContainer);
local ms_IconAndTextIM:table = InstanceManager:new("IconAndText", "SelectButton", Controls.IconAndTextContainer);
local ms_AIOfferListIM:table = InstanceManager:new("AIExchangeOfferRowInstance", "OfferRowContainer", Controls.AIOffersStack);

local m_GoldType = GOLD_TYPE.ONE_TIME;
local m_SortBy = SORT_BY.EACH;

local m_LocalPlayer = nil;
local m_AIPlayers = {};
local m_AIOffers = {};
local m_AcceptedPlayer = -1;
local m_LeaderUniqueness = {};

-- ===========================================================================
--  Initialization
-- ===========================================================================
function CreatePanels()
    InitializePullDowns();
end

function InitializePullDowns()
    PopulatePullDown(Controls.GoldTypeFilter, GOLD_TYPE_OPTIONS, m_GoldType, function(option)
        if option ~= m_GoldType then
            m_GoldType = option;
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

-- ===========================================================================
--  Helper functions
-- ===========================================================================
-- Return: Can skip refetch or not.
function UpdateAIOffersAfterAccept()
    if m_AcceptedPlayer ~= -1 then
        -- Remove accepted offer from current list.
        local removedIndex = -1;
        for index, offer in ipairs(m_AIOffers) do
            if m_AcceptedPlayer == offer.PlayerId then
                removedIndex = index;
                break;
            end
        end
        m_AcceptedPlayer = -1;
        local removedOffer = table.remove(m_AIOffers, removedIndex);
        local deal = DealManager.GetWorkingDeal(DealDirection.OUTGOING, m_LocalPlayer:GetID(), removedOffer.PlayerId);
        local goldDetails = GetPlayerGoldInDeal(deal, m_LocalPlayer:GetID());
        local isPlayerOTG = m_GoldType ~= GOLD_TYPE.ONE_TIME;
        -- Check if remaining offers are valid.
        for _, offer in ipairs(m_AIOffers) do
            if isPlayerOTG and goldDetails.MaxOneTimeGold < offer.OneTimeGold then
                return false;
            elseif not isPlayerOTG and goldDetails.MaxMultiTurnGold < offer.MultiTurnGold then
                return false;
            end
        end
    end
    return true;
end
-- ===========================================================================
--  Populating data
-- ===========================================================================
function PopulateAIOfferPanel()
    m_AIOffers = SortOffers(m_AIOffers, m_SortBy, false);
    ms_AIOfferListIM:ResetInstances();
    for _, offer in ipairs(m_AIOffers) do
        if offer.OneTimeGold ~= 0 or offer.MultiTurnGold ~= 0 or offer.HasNonGoldItem then
            if table.count(offer.OfferedItems) == 1 then -- Should only have 1 item which is one time gold or multi turn gold.
                local offerControl = ms_AIOfferListIM:GetInstance(Controls.AIOffersStack);
                PopulateAIOffer(offer, offerControl);
            end
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
    -- Set offer info.
    local aiItem = offer.OfferedItems[1]; -- Should only have 1 item which is one time gold or multi turn gold.
    -- Get max multi turn gold.
    local mtgPlayer = m_LocalPlayer:GetID();
    if aiItem.Duration > 0 then mtgPlayer = offer.PlayerId; end
    local deal = DealManager.GetWorkingDeal(DealDirection.OUTGOING, m_LocalPlayer:GetID(), offer.PlayerId);
    local mtgMaxAmount = GetPlayerGoldInDeal(deal, mtgPlayer).MaxMultiTurnGold;
    -- Set offered gold.
    local ratio = 0;
    if aiItem.Duration == 0 then
        ratio = aiItem.Amount / offer.MultiTurnGold;
    else
        ratio = offer.OneTimeGold / aiItem.Amount;
    end
    if aiItem.Duration == 0 then
        -- Set AI one time gold.
        offerControl.AIMultiTurnGold.SelectButton:SetHide(true);
        offerControl.AIOneTimeGold.SelectButton:SetHide(false);
        SetIconToSize(offerControl.AIOneTimeGold.Icon, "ICON_YIELD_GOLD_5");
        offerControl.AIOneTimeGold.Icon:SetColor(1,1,1);
        offerControl.AIOneTimeGold.AmountText:SetText(aiItem.Amount);
        offerControl.AIOneTimeGold.RemoveButton:SetHide(true);
        offerControl.AIOneTimeGold.SelectButton:SetDisabled(true);
        -- Set player multi turn gold.
        offerControl.OneTimeGold.SelectButton:SetHide(true);
        offerControl.MultiTurnGold.SelectButton:SetHide(false);
        SetIconToSize(offerControl.MultiTurnGold.Icon, "ICON_YIELD_GOLD_5");
        offerControl.MultiTurnGold.Icon:SetColor(1,1,1);
        offerControl.MultiTurnGold.AmountText:SetText(offer.MultiTurnGold);
        offerControl.MultiTurnGold.IconText:LocalizeAndSetText("LOC_DIPLOMACY_DEAL_FOR_TURNS", 30);
        offerControl.MultiTurnGold.ValueText:SetHide(true);
        offerControl.MultiTurnGold.RemoveButton:SetHide(true);
        offerControl.MultiTurnGold.SelectButton:SetDisabled(false);
        offerControl.MultiTurnGold.SelectButton:RegisterCallback(
            Mouse.eLClick, function() AttachValueEdit(offer.PlayerId, offer.MultiTurnGold, mtgMaxAmount, offerControl, true, ratio); end);
        -- Hook up multi turn gold change handlers.
        offerControl.AIMTGArrows:SetHide(true);
        offerControl.MTGArrows:SetHide(false);
        offerControl.IncreaseMTG:SetDisabled(offer.MultiTurnGold >= mtgMaxAmount);
        offerControl.DecreaseMTG:SetDisabled(offer.MultiTurnGold <= 1);
        offerControl.IncreaseMTG:RegisterCallback(Mouse.eLClick, function() OnUpdateMultiTurnGold(offer.PlayerId, 1, offerControl, true, ratio); end);
        offerControl.DecreaseMTG:RegisterCallback(Mouse.eLClick, function() OnUpdateMultiTurnGold(offer.PlayerId, -1, offerControl, true, ratio); end);
    else
        -- Set AI multi turn gold.
        offerControl.AIOneTimeGold.SelectButton:SetHide(true);
        offerControl.AIMultiTurnGold.SelectButton:SetHide(false);
        SetIconToSize(offerControl.AIMultiTurnGold.Icon, "ICON_YIELD_GOLD_5");
        offerControl.AIMultiTurnGold.Icon:SetColor(1,1,1);
        offerControl.AIMultiTurnGold.AmountText:SetText(aiItem.Amount);
        offerControl.AIMultiTurnGold.IconText:LocalizeAndSetText("LOC_DIPLOMACY_DEAL_FOR_TURNS", 30);
        offerControl.AIMultiTurnGold.ValueText:SetHide(true);
        offerControl.AIMultiTurnGold.RemoveButton:SetHide(true);
        offerControl.AIMultiTurnGold.SelectButton:SetDisabled(false);
        offerControl.AIMultiTurnGold.SelectButton:RegisterCallback(
            Mouse.eLClick, function() AttachValueEdit(offer.PlayerId, aiItem.Amount, mtgMaxAmount, offerControl, false, ratio); end);
        -- Set player one time gold.
        offerControl.MultiTurnGold.SelectButton:SetHide(true);
        offerControl.OneTimeGold.SelectButton:SetHide(false);
        SetIconToSize(offerControl.OneTimeGold.Icon, "ICON_YIELD_GOLD_5");
        offerControl.OneTimeGold.Icon:SetColor(1,1,1);
        offerControl.OneTimeGold.AmountText:SetText(offer.OneTimeGold);
        offerControl.OneTimeGold.RemoveButton:SetHide(true);
        offerControl.OneTimeGold.SelectButton:SetDisabled(true);
        -- Hook up multi turn gold change handlers.
        offerControl.AIMTGArrows:SetHide(false);
        offerControl.MTGArrows:SetHide(true);
        offerControl.AIIncreaseMTG:SetDisabled(aiItem.Amount >= mtgMaxAmount);
        offerControl.AIDecreaseMTG:SetDisabled(aiItem.Amount <= 1);
        offerControl.AIIncreaseMTG:RegisterCallback(Mouse.eLClick, function() OnUpdateMultiTurnGold(offer.PlayerId, 1, offerControl, false, ratio); end);
        offerControl.AIDecreaseMTG:RegisterCallback(Mouse.eLClick, function() OnUpdateMultiTurnGold(offer.PlayerId, -1, offerControl, false, ratio); end);
    end
    offerControl.GoldRatio:SetText(string.format("%.1f : 1[ICON_Turn]", ratio));
    -- Hook up accept deal button.
    offerControl.AcceptDeal:SetHide(false);
    offerControl.AcceptDeal:RegisterCallback(Mouse.eLClick, function() OnAcceptDeal(offer.PlayerId); end);
    offerControl.AcceptDeal:RegisterCallback(Mouse.eMouseEnter, function() UI.PlaySound("Main_Menu_Mouse_Over"); end);
end

function ResetAIOfferPanel()
    m_AIOffers = {};
    PopulateAIOfferPanel();
end

-- ===========================================================================
--  Multi turn gold editing
-- ===========================================================================
function AttachValueEdit(otherPlayerId, amount, maxAmount, controlInstance, isPlayerMTG, goldRatio)
    Controls.ValueEditIconGrid:SetHide(false);
    Controls.ValueAmountEditBoxContainer:SetHide(false);
    Controls.ValueEditHeaderLabel:SetText(Locale.Lookup("LOC_DIPLOMACY_DEAL_HOW_MANY"));
    Controls.ValueEditValueText:LocalizeAndSetText("LOC_DIPLOMACY_DEAL_FOR_TURNS", 30);
    Controls.ValueEditValueText:SetHide(false);
    SetIconToSize(Controls.ValueEditIcon, "ICON_YIELD_GOLD_5");
    Controls.ValueEditAmountText:SetText(amount);
    Controls.ValueEditAmountText:SetHide(false);
    Controls.ValueAmountEditBox:SetText(amount);
    Controls.ValueEditButton:RegisterCallback(Mouse.eLClick, function() OnValueEditButton(otherPlayerId, amount, maxAmount, controlInstance, isPlayerMTG, goldRatio); end);
    Controls.ValueAmountEditLeftButton:RegisterCallback(Mouse.eLClick, function() OnValueAmountEditDelta(maxAmount, -1); end);
    Controls.ValueAmountEditRightButton:RegisterCallback(Mouse.eLClick, function() OnValueAmountEditDelta(maxAmount, 1); end);
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
function UpdateAIDeals()
    ResetAIOfferPanel();
    UpdateFetchStatus(true, false);
    LuaEvents.QD_StartAIGoldExchange(m_LocalPlayer:GetID(), m_AIPlayers, m_GoldType ~= GOLD_TYPE.ONE_TIME);
end

function UpdateFetchStatus(isFetching:boolean, hasOffers:boolean)
    Controls.FetchingDealLabel:SetHide(not isFetching);
    Controls.NoAvailableDealLabel:SetHide(isFetching or hasOffers);
end

-- ===========================================================================
--  UI event callbacks
-- ===========================================================================
function OnAcceptDeal(otherPlayerId)
    m_AcceptedPlayer = otherPlayerId;
    -- Don't need to check DealManager.AreWorkingDealsEqual(), since the deal won't be equal.
    LuaEvents.QD_StartAIOfferAccept(m_LocalPlayer:GetID(), otherPlayerId);
end

function OnShowDealDetails(otherPlayerId)
    LuaEvents.QD_RequestDealScreen(otherPlayerId);
end

function OnUpdateMultiTurnGold(otherPlayerId, delta, controlInstance, isPlayerMTG, goldRatio)
    LuaEvents.QD_StartMultiTurnGoldUpdate(m_LocalPlayer:GetID(), otherPlayerId, delta, controlInstance, isPlayerMTG, true, goldRatio);
end

function OnValueEditButton(otherPlayerId, amount, maxAmount, controlInstance, isPlayerMTG, goldRatio)
    local newAmount:number = tonumber(Controls.ValueAmountEditBox:GetText() or 0);
    newAmount = math.min(newAmount, maxAmount);
    newAmount = math.max(newAmount, 1);
    if newAmount ~= amount then
        local delta = newAmount - amount;
        OnUpdateMultiTurnGold(otherPlayerId, delta, controlInstance, isPlayerMTG, goldRatio);
    end
    Controls.ValueEditPopupBackground:SetHide(true);
end

function OnValueAmountEditDelta(maxAmount, delta)
    local newAmount:number = tonumber(Controls.ValueAmountEditBox:GetText() or 0) + delta;
    newAmount = math.min(newAmount, maxAmount);
    newAmount = math.max(newAmount, 1);
    Controls.ValueAmountEditBox:SetText(newAmount);
end

-- ===========================================================================
--  Event handlers
-- ===========================================================================
function OnEndAIOfferAccept(myOfferedItemsInDeal:table)
    if not ContextPtr:IsHidden() then
        if UpdateAIOffersAfterAccept() then
            -- Can skip refetch.
            PopulateAIOfferPanel();
            UpdateFetchStatus(false, #m_AIOffers > 0);
        else
            UpdateAIDeals();
        end
        UI.PlaySound("Confirm_Bed_Positive");
    end
end

function OnEndAIGoldExchange(aiOffers:table)
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
    if tabType == TAB_TYPE.EXCHANGE then
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
        OnShowTab(TAB_TYPE.EXCHANGE);
    end
end

function QD_Initialize()
    ContextPtr:SetInitHandler(OnInit);
    ContextPtr:SetAutoSize(true);
    ContextPtr:SetHide(true);

    LuaEvents.QD_EndAIOfferAccept.Add(OnEndAIOfferAccept);
    LuaEvents.QD_EndAIGoldExchange.Add(OnEndAIGoldExchange);
    LuaEvents.QD_EndMultiTurnGoldUpdate.Add(OnEndMultiTurnGoldUpdate);
    LuaEvents.QD_PopupShowTab.Add(OnShowTab);
end

QD_Initialize();