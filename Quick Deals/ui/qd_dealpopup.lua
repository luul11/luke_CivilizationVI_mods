include("InstanceManager");
include("ModalScreen_PlayerYieldsHelper");
include("TabSupport");

include("qd_utils");

-- ===========================================================================
--  CONSTANTS
-- ===========================================================================
local TAB_SIZE:number = 170;
local TAB_PADDING:number = 10;

-- ===========================================================================
--  MEMBERS
-- ===========================================================================
local m_TabButtonIM:table = InstanceManager:new("TabButtonInstance", "Button", Controls.TabContainer);
local m_OpenPopupActionId:number = Input.GetActionId("OpenQDPopup");

local m_TopPanelConsideredHeight:number = 0;
local m_Tabs;
local m_NumOfTabs = 0;
local m_SaleTabInstance:table = nil;
local m_PurchaseTabInstance:table = nil;
local m_ExchangeTabInstance:table = nil;

-- ===========================================================================
--  Functions.
-- ===========================================================================
function Open()
    local localPlayer = Game.GetLocalPlayer();
    if localPlayer == -1 or not Players[localPlayer]:IsTurnActive() then return; end

    CloseOtherPanels();
    -- Queue the screen as a popup, but we want it to render at a desired location in the hierarchy, not on top of everything.
    if not UIManager:IsInPopupQueue(ContextPtr) then
        local kParameters = {};
        kParameters.RenderAtCurrentParent = true;
        kParameters.InputAtCurrentParent = true;
        kParameters.AlwaysVisibleInQueue = true;
        UIManager:QueuePopup(ContextPtr, PopupPriority.Low, kParameters);
        -- Change our parent to be 'Screens' so the navigational hooks draw on top of it.
        ContextPtr:ChangeParent(ContextPtr:LookUpControl("/InGame/Screens"));
        UI.PlaySound("UI_Screen_Open");
        LuaEvents.QDDealPopup_Opened();
    end
    -- Default to sale tab.
    m_Tabs.SelectTab(m_SaleTabInstance.Button);
    -- From ModalScreen_PlayerYieldsHelper
    if not RefreshYields() then
        Controls.Vignette:SetSizeY(m_TopPanelConsideredHeight);
    end
    -- From Civ6_styles: FullScreenVignetteConsumer
    Controls.ScreenAnimIn:SetToBeginning();
    Controls.ScreenAnimIn:Play();
end

function Close()
    if UIManager:DequeuePopup(ContextPtr) then
        LuaEvents.QDDealPopup_CloseRequest();
        UI.PlaySound("UI_Screen_Close");
    end
end

function CloseSilently()
    UIManager:DequeuePopup(ContextPtr);
end

function OnSaleTabClick(uiSelectedButton:table)
    ResetTabButtons();
    SetTabButtonsSelected(uiSelectedButton);
    LuaEvents.QD_PopupShowTab(TAB_TYPE.SALE);
end

function OnPurchaseTabClick(uiSelectedButton:table)
    ResetTabButtons();
    SetTabButtonsSelected(uiSelectedButton);
    LuaEvents.QD_PopupShowTab(TAB_TYPE.PURCHASE);
end

function OnExchangeTabClick(uiSelectedButton:table)
    ResetTabButtons();
    SetTabButtonsSelected(uiSelectedButton);
    LuaEvents.QD_PopupShowTab(TAB_TYPE.EXCHANGE);
end

function CloseOtherPanels()
    LuaEvents.LaunchBar_CloseTechTree();
    LuaEvents.LaunchBar_CloseCivicsTree();
    LuaEvents.LaunchBar_CloseGovernmentPanel();
    LuaEvents.LaunchBar_CloseReligionPanel();
    LuaEvents.LaunchBar_CloseGreatPeoplePopup();
    LuaEvents.LaunchBar_CloseGreatWorksOverview();
    if g_IsXP1Active then
        LuaEvents.GovernorPanel_Close();
        LuaEvents.HistoricMoments_Close();
    end
    if g_IsXP2Active then
        LuaEvents.Launchbar_Expansion2_ClimateScreen_Close();
    end
end

-- ===========================================================================
--  Tab setup
-- ===========================================================================
function SetupTabs()
    m_NumOfTabs = 0;

    -- Tab setup and setting of default tab.
    m_Tabs = CreateTabs(Controls.TabContainer, 42, 34, UI.GetColorValueFromHexLiteral(0xFF331D05));

    m_SaleTabInstance = AddTabInstance("LOC_QD_SALE", OnSaleTabClick);
    m_PurchaseTabInstance = AddTabInstance("LOC_HUD_PURCHASE", OnPurchaseTabClick);
    m_ExchangeTabInstance = AddTabInstance("LOC_QD_EXCHANGE", OnExchangeTabClick);

    local desiredSize = (TAB_SIZE * m_NumOfTabs) + (TAB_PADDING * (m_NumOfTabs - 1));
    Controls.TabContainer:SetSizeX(desiredSize);

    m_Tabs.CenterAlignTabs(-10);
    m_Tabs.SelectTab(m_SaleTabInstance.Button);
end

function AddTabInstance(buttonText:string, callbackFunc:ifunction)
    local kInstance:object = m_TabButtonIM:GetInstance();
    kInstance.Button:SetText(Locale.Lookup(buttonText));
    kInstance.Button:RegisterCallback(Mouse.eMouseEnter, function() UI.PlaySound("Main_Menu_Mouse_Over"); end);
    m_Tabs.AddTab(kInstance.Button, callbackFunc);
    m_NumOfTabs = m_NumOfTabs + 1;
    return kInstance;
end

function SetTabButtonsSelected(buttonControl:table)
    for i=1, m_TabButtonIM.m_iCount, 1 do
        local buttonInstance:table = m_TabButtonIM:GetAllocatedInstance(i);
        if buttonInstance and buttonInstance.Button == buttonControl then
            buttonInstance.Button:SetSelected(true);
            buttonInstance.SelectButton:SetHide(false);
        end
    end
end

function ResetTabButtons()
    for i=1, m_TabButtonIM.m_iCount, 1 do
        local buttonInstance:table = m_TabButtonIM:GetAllocatedInstance(i);
        if buttonInstance then
            buttonInstance.Button:SetSelected(false);
            buttonInstance.SelectButton:SetHide(true);
        end
    end
end

-- ===========================================================================
--  Event handlers
-- ===========================================================================
function OnInit(isReload)
    SetupTabs();
    if isReload and not ContextPtr:IsHidden() then
        Open();
    end
end

function OnInputHandler(pInputStruct:table)
    if ContextPtr:IsHidden() then return false; end
    if pInputStruct:GetMessageType() == KeyEvents.KeyUp and pInputStruct:GetKey() == Keys.VK_ESCAPE then 
        Close();
    end
    -- Handle all key events so player cannot proceed to next turn through key presses.
    return true;
end

function OnInputActionTriggered(actionId:number)
    if actionId == m_OpenPopupActionId and ContextPtr:IsHidden() then
        -- Only add action for opening popup, since all key events are blocked when popup is shown.
        Open();
    end
end

function OnShutdown()
    m_TabButtonIM:ResetInstances();
    -- LUA Events
    LuaEvents.QD_RequestDealScreen.Remove(OnRequestDealScreen);
    LuaEvents.QD_ToggleDealPopup.Remove(ToggleDealPopup);
    LuaEvents.QD_CloseDealPopupSilently.Remove(CloseSilently);
end

function OnProcessNotification(playerId:number, notificationId:number, activatedByUser:boolean)
    if playerId == Game.GetLocalPlayer() then
        local notification = NotificationManager.Find(playerId, notificationId);
        if notification and notification:GetType() == QD_NOTIFICATION_HASH and ContextPtr:IsHidden() then
            Open();
        end
    end
end

function ToggleDealPopup()
    if ContextPtr:IsHidden() then
        Open();
    else
        Close();
    end
end

function OnRequestDealScreen(otherPlayerId)
    -- Close the popup first.
    Close();
    -- Request a deal session with the given player. The current deal items will be auto populated.
    DiplomacyManager.RequestSession(Game.GetLocalPlayer(), otherPlayerId, "MAKE_DEAL");
end

function QD_Initialize()
    ContextPtr:SetInitHandler(OnInit);
    ContextPtr:SetInputHandler(OnInputHandler, true);
    ContextPtr:SetShutdown(OnShutdown);

    Events.InputActionTriggered.Add(OnInputActionTriggered);
    Events.NotificationActivated.Add(OnProcessNotification);

    LuaEvents.QD_RequestDealScreen.Add(OnRequestDealScreen);
    LuaEvents.QD_ToggleDealPopup.Add(ToggleDealPopup);
    LuaEvents.QD_CloseDealPopupSilently.Add(CloseSilently);

    Controls.ModalScreenClose:RegisterCallback(Mouse.eLClick, Close);
    Controls.ModalScreenTitle:SetText(Locale.ToUpper(Locale.Lookup("LOC_QD_NAME")));

    if GameConfiguration.IsAnyMultiplayer() then
        Controls.NotificationToggle:LocalizeAndSetToolTip("LOC_QD_NOT_SUPPORTED_IN_MULTIPLAYER");
        Controls.NotificationToggle:SetDisabled(true);
        Controls.NotificationToggle:SetCheck(false);
    else
        Controls.NotificationToggle:LocalizeAndSetToolTip("LOC_OPTIONS_NOTIFICATIONS");
        Controls.NotificationToggle:RegisterCallback(Mouse.eLClick, ToggleNotificationOptedOut);
        Controls.NotificationToggle:SetDisabled(false);
        Controls.NotificationToggle:SetCheck(not IsNotificationOptedOut());
    end

    m_TopPanelConsideredHeight = Controls.Vignette:GetSizeY() - TOP_PANEL_OFFSET;
end

QD_Initialize();
