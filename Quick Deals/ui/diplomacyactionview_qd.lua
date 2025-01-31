-- =================================================================================
-- Import base file
-- =================================================================================
local files = {
    "DiplomacyActionView_Expansion2.lua",
    "DiplomacyActionView_Expansion1.lua",
    "DiplomacyActionView.lua"
}

for _, file in ipairs(files) do
    include(file);
    if Initialize then
        print("QD_DiplomacyActionView loading " .. file .. " as base file");
        break;
    end
end

-- =================================================================================
-- Cache base functions
-- =================================================================================
QD_BASE_LateInitialize = LateInitialize;
QD_BASE_OnDiplomacyStatement = OnDiplomacyStatement;

-- ===========================================================================
local m_QDPopupShowing = false;

-- ===========================================================================
function OnDiplomacyStatement(fromPlayer:number, toPlayer:number, kVariants:table)
    -- print("OnDiplomacyStatement: ", kVariants.StatementType, kVariants.RespondingToDealAction, kVariants.DealAction, kVariants.SessionID, fromPlayer, toPlayer, m_QDPopupShowing);
    if m_QDPopupShowing then
        local statementTypeName = DiplomacyManager.GetKeyName(kVariants.StatementType);
        if statementTypeName == "MAKE_DEAL" then
            return;
        else
            LuaEvents.QD_OnSurpriseSession(kVariants.SessionID);
            LuaEvents.QD_CloseDealPopupSilently();
        end
    end
    QD_BASE_OnDiplomacyStatement(fromPlayer, toPlayer, kVariants);
end

function OnDealPopupOpened()
    m_QDPopupShowing = true;
end

function OnDealPopupClosed()
    m_QDPopupShowing = false;
end

function LateInitialize()
	QD_BASE_LateInitialize();

    Events.DiplomacyStatement.Remove(QD_BASE_OnDiplomacyStatement);
    Events.DiplomacyStatement.Add(OnDiplomacyStatement);
    
    LuaEvents.QDDealPopup_Closed.Add(OnDealPopupClosed);
    LuaEvents.QDDealPopup_Opened.Add(OnDealPopupOpened);
end