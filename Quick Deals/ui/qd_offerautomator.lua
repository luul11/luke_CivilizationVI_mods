include("qd_utils");

local JOB_TYPE = {
    FETCH = 1,
    ACCEPT = 2,
    EXCHANGE = 3,
    MTGUPDATE = 4,
};

local m_PlayerId = -1;
local m_IsFetching = false;
local m_IsAccepting = false;
local m_IsExchanging = false;
local m_IsMTGUpdating = false;

local m_PendingJob = nil;

-- Flags to assist proper popup closing.
local m_AwaitingResponse = nil;
local m_PopupCloseRequested = false;

-- For AI offer fetch and gold exchange.
local m_AIListToCheck = {};
local m_AISellingType = nil;
local m_AISellingSubType = nil;
local m_MyOfferedItems = {};
local m_AIIndex = 1;

-- For AI offer accept.
local m_MyOfferedItemsInDeal = {};

-- For AI gold exchange.
local m_IsPlayerOTG = false;
local m_MultiTurnGoldFound = false;
local CHECKING_DELTAS = {1000, 100, 10, 1};
local OTG_CHECK_DELTA_INDEX = 1;
for index, value in ipairs(CHECKING_DELTAS) do
     -- Set to first delta that's less than 30.
    if value < 30 then OTG_CHECK_DELTA_INDEX = index; break; end
end
local m_DeltaIndex = 1;

-- For MTG Update.
local m_IsPlayerMTG = false;
local m_IsGoldExchange = false;
local m_MultiTurnGoldDelta = 0;
local m_GoldRatio = GOLD_RATIO;
local m_ControlInstance = nil;
local m_LastAcceptedGold = {};

local m_Offers = {}; -- offer => ({ OneTimeGold: 5, MultiTurnGold: 3, Total: 95, PlayerId: 1})

-- Callback for receiving AI's deal responses.
function OnDiplomacyStatement(fromPlayer:number, toPlayer:number, kVariants:table)
    -- print("OnDiplomacyStatement", fromPlayer, kVariants.RespondingToDealAction, kVariants.DealAction, kVariants.SessionID);
    -- Don't need to handle if the event is not sent to the local player.
    if toPlayer ~= m_PlayerId then return; end
    if not HasJobRunning() then return; end
    if m_AwaitingResponse == nil
        or m_AwaitingResponse.PlayerId ~= fromPlayer
        or m_AwaitingResponse.DealAction ~= kVariants.RespondingToDealAction then
            return;
    end

    if m_PopupCloseRequested then
        -- Consume awaited response and request popup close again.
        m_IsFetching = false;
        m_IsAccepting = false;
        m_IsExchanging = false;
        m_IsMTGUpdating = false;
        m_AwaitingResponse = nil;
        FinishPopupClose();
        return;
    end

    local statementTypeName = DiplomacyManager.GetKeyName(kVariants.StatementType);
    if statementTypeName == "MAKE_DEAL" then
        local statementSubTypeName = DiplomacyManager.GetKeyName(kVariants.StatementSubType);
        local lastDealAction = kVariants.RespondingToDealAction;
        if m_IsAccepting then
            if lastDealAction == 0 then
                m_AwaitingResponse = nil;
                ContinueAIOfferAccept(fromPlayer, lastDealAction, kVariants.DealAction, kVariants.SessionID, statementSubTypeName);
            end
        elseif m_IsFetching then
            if lastDealAction == 0 or lastDealAction == DealProposalAction.INSPECT or lastDealAction == DealProposalAction.EQUALIZE then
                m_AwaitingResponse = nil;
                ContinueAIOfferFetch(lastDealAction, kVariants.DealAction, kVariants.SessionID, statementSubTypeName);
            end
        elseif m_IsExchanging then
            if lastDealAction == 0 or lastDealAction == DealProposalAction.INSPECT then
                m_AwaitingResponse = nil;
                ContinueAIGoldExchange(lastDealAction, kVariants.DealAction, kVariants.SessionID, statementSubTypeName);
            end
        elseif m_IsMTGUpdating then
            if lastDealAction == 0 or lastDealAction == DealProposalAction.INSPECT or lastDealAction == DealProposalAction.EQUALIZE then
                m_AwaitingResponse = nil;
                ContinueMultiTurnGoldUpdate(fromPlayer, lastDealAction, kVariants.DealAction, kVariants.SessionID, statementSubTypeName);
            end
        end
    end
end

function OnStartAIOfferFetch(playerId:number, aiListToCheck:table, myOfferedItems:table, aiSellingType, aiSellingSubType)
    if HasJobRunning() then
        -- Add the request to pending queue if there's an existing job.
        local taskArgs = {};
        table.insert(taskArgs, playerId);
        table.insert(taskArgs, aiListToCheck);
        table.insert(taskArgs, myOfferedItems);
        table.insert(taskArgs, aiSellingType);
        table.insert(taskArgs, aiSellingSubType);
        m_PendingJob = {
            Type = JOB_TYPE.FETCH,
            Args = taskArgs
        }
        return;
    end
    m_PlayerId = playerId;
    m_IsFetching = true;
    m_AISellingType = aiSellingType;
    m_AISellingSubType = aiSellingSubType;
    m_MyOfferedItems = myOfferedItems;
    m_Offers = {};
    m_AIListToCheck = aiListToCheck;
    m_AIIndex = 1;
    ContinueAIOfferFetch();
end

function EndAIOfferFetch()
    m_IsFetching = false;
    if not ProceedPendingJob() then
        LuaEvents.QD_EndAIOfferFetch(m_Offers);
    end
end

-- Return whether AI offer fetch is ended or not.
function ContinueAIOfferFetch(lastDealAction:number, responseAction, sessionId, statementSubTypeName)
    if m_AIIndex > #m_AIListToCheck then
        EndAIOfferFetch();
        return;
    end

    local otherPlayerId = m_AIListToCheck[m_AIIndex];
    if lastDealAction == nil then
        -- First start.
        DealManager.ClearWorkingDeal(DealDirection.OUTGOING, m_PlayerId, otherPlayerId);
        local existSessionId = DiplomacyManager.FindOpenSessionID(m_PlayerId, otherPlayerId);
        if existSessionId ~= nil then
            -- If there's an existing session with this AI, proceed to the next step.
            ContinueAIOfferFetch(0, 0, existSessionId);
        else
            DiplomacyManager.RequestSession(m_PlayerId, otherPlayerId, "MAKE_DEAL");
            m_AwaitingResponse = { PlayerId = otherPlayerId, DealAction = 0 };
        end
    elseif lastDealAction == 0 then
        -- Initialized.
        local deal = DealManager.GetWorkingDeal(DealDirection.OUTGOING, m_PlayerId, otherPlayerId);
        if deal then
            if m_AISellingType ~= nil then
                AddAIOfferedItemsToDeal(deal, otherPlayerId);
            else
                AddHumanOfferedItemsToDeal(deal, otherPlayerId);
            end
        end
        SendDealForInspection(deal, otherPlayerId, sessionId);
    elseif lastDealAction == DealProposalAction.INSPECT then
        local itemCountFromLocal = 0;
        local itemCountFromOther = 0;
        local deal = DealManager.GetWorkingDeal(DealDirection.OUTGOING, m_PlayerId, otherPlayerId);
        if deal then
            itemCountFromLocal = deal:GetItemCount(m_PlayerId, otherPlayerId);
            itemCountFromOther = deal:GetItemCount(otherPlayerId, m_PlayerId);
        end
        if itemCountFromLocal == 0 and itemCountFromOther == 0 then
            ContinueToNextAIOfferFetch(otherPlayerId, sessionId);
        elseif itemCountFromLocal > 0 and itemCountFromOther > 0 then
            -- Both sides have items, check if AI accepts this deal.
            if responseAction == DealProposalAction.ACCEPTED then
                ContinueToNextAIOfferFetch(otherPlayerId, sessionId);
            elseif responseAction == DealProposalAction.REJECTED then
                -- TODO: Rework the deal and propose again.
                DiplomacyManager.CloseSession(sessionId);
                m_AIIndex = m_AIIndex + 1;
                ContinueAIOfferFetch();
            end
        else
            -- Inspected, send equalize request if one of the sides doesn't have items.
            DealManager.SendWorkingDeal(DealProposalAction.EQUALIZE, m_PlayerId, otherPlayerId);
            m_AwaitingResponse = { PlayerId = otherPlayerId, DealAction = DealProposalAction.EQUALIZE };
            StartEqualizeRequestTimer(otherPlayerId, sessionId);
        end
    elseif lastDealAction == DealProposalAction.EQUALIZE then
        if responseAction == DealProposalAction.EQUALIZE_FAILED and m_AISellingType == nil then
            -- Equalize failed when selling to AI, try inspect with all AI's gold.
            local deal = DealManager.GetWorkingDeal(DealDirection.OUTGOING, m_PlayerId, otherPlayerId);
            if deal and AddAllAIGoldToDeal(deal, otherPlayerId) then
                SendDealForInspection(deal, otherPlayerId, sessionId);
            else
                -- AI doesn't have any gold left, move to the next AI.
                ContinueToNextAIOfferFetch(otherPlayerId, sessionId);
            end
        else
            -- Offer equalized, store the deal and proceed with next player.
            DealManager.CopyIncomingToOutgoingWorkingDeal(m_PlayerId, otherPlayerId);
            ContinueToNextAIOfferFetch(otherPlayerId, sessionId);
        end
    end
end

function ContinueToNextAIOfferFetch(otherPlayerId, sessionId)
    local deal = DealManager.GetWorkingDeal(DealDirection.OUTGOING, m_PlayerId, otherPlayerId);
    if deal then
        table.insert(m_Offers, GetPlayerOfferInDeal(deal, m_PlayerId, otherPlayerId, m_AISellingType ~= nil));
    end
    -- Close the session with the current AI before moving to the next AI.
    DiplomacyManager.CloseSession(sessionId);
    -- Move to the next AI.
    m_AIIndex = m_AIIndex + 1;
    ContinueAIOfferFetch();
end

function OnStartMultiTurnGoldUpdate(playerId:number, otherPlayerId:number, delta:number, controlInstance, isPlayerMTG:boolean, isGoldExchange, goldRatio)
    if HasJobRunning() then
        -- Add the request to pending queue if there's an existing job.
        local taskArgs = {};
        table.insert(taskArgs, playerId);
        table.insert(taskArgs, otherPlayerId);
        table.insert(taskArgs, delta);
        table.insert(taskArgs, controlInstance);
        table.insert(taskArgs, isAISelling);
        m_PendingJob = {
            Type = JOB_TYPE.MTGUPDATE,
            Args = taskArgs
        }
        return;
    end
    m_PlayerId = playerId;
    m_IsMTGUpdating = true;
    m_IsPlayerMTG = isPlayerMTG or false;
    m_IsGoldExchange = isGoldExchange or false;
    m_MultiTurnGoldDelta = delta;
    m_GoldRatio = goldRatio or GOLD_RATIO;
    m_ControlInstance = controlInstance;
    m_LastAcceptedGold = {};
    m_Offers = {};
    ContinueMultiTurnGoldUpdate(otherPlayerId);
end

function EndMultiTurnGoldUpdate()
    m_IsMTGUpdating = false;
    if not ProceedPendingJob() then
        LuaEvents.QD_EndMultiTurnGoldUpdate(m_Offers, m_ControlInstance);
    end
end

function ContinueMultiTurnGoldUpdate(otherPlayerId, lastDealAction:number, responseAction, sessionId, statementSubTypeName)
    local mtgPlayerId = otherPlayerId;
    local otgPlayerId = m_PlayerId;
    if m_IsPlayerMTG then
        mtgPlayerId = m_PlayerId;
        otgPlayerId = otherPlayerId;
    end
    if not m_IsGoldExchange then otgPlayerId = mtgPlayerId; end
    if lastDealAction == nil then
        -- First start, don't clear working deal.
        local existSessionId = DiplomacyManager.FindOpenSessionID(m_PlayerId, otherPlayerId);
        if existSessionId ~= nil then
            -- If there's an existing session with this AI, proceed to the next step.
            ContinueMultiTurnGoldUpdate(0, 0, existSessionId);
        else
            DiplomacyManager.RequestSession(m_PlayerId, otherPlayerId, "MAKE_DEAL");
            m_AwaitingResponse = { PlayerId = otherPlayerId, DealAction = 0 };
        end
    elseif lastDealAction == 0 then
        -- Initialized.
        local deal = DealManager.GetWorkingDeal(DealDirection.OUTGOING, m_PlayerId, otherPlayerId);
        if deal then
            local mtgDetails = GetPlayerGoldInDeal(deal, mtgPlayerId);
            local otgDetails = GetPlayerGoldInDeal(deal, otgPlayerId);
            m_LastAcceptedGold.OneTimeGold = otgDetails.OneTimeGold;
            m_LastAcceptedGold.MultiTurnGold = mtgDetails.MultiTurnGold;
            -- Update the deal
            local newMultiTurnGold = mtgDetails.MultiTurnGold + m_MultiTurnGoldDelta;
            newMultiTurnGold = math.max(newMultiTurnGold, 0);
            newMultiTurnGold = math.min(newMultiTurnGold, mtgDetails.MaxMultiTurnGold);
            local multiTurnGoldDelta = newMultiTurnGold - mtgDetails.MultiTurnGold;
            if multiTurnGoldDelta == 0 then
                -- Not possible to update multi turn gold, just end the update.
                DiplomacyManager.CloseSession(sessionId);
                EndMultiTurnGoldUpdate();
                return;
            end
            local oneTimeGoldDelta = -multiTurnGoldDelta * m_GoldRatio;
            if m_IsGoldExchange then oneTimeGoldDelta = -oneTimeGoldDelta; end
            UpdatePlayerGoldInDeal(deal, mtgPlayerId, 0, multiTurnGoldDelta);
            UpdatePlayerGoldInDeal(deal, otgPlayerId, oneTimeGoldDelta, 0);
        end
        SendDealForInspection(deal, otherPlayerId, sessionId);
    elseif lastDealAction == DealProposalAction.INSPECT then
        local deal = DealManager.GetWorkingDeal(DealDirection.OUTGOING, m_PlayerId, otherPlayerId);
        local mtgDetails = GetPlayerGoldInDeal(deal, mtgPlayerId);
        local otgDetails = GetPlayerGoldInDeal(deal, otgPlayerId);
        if responseAction == DealProposalAction.ACCEPTED then
            local delta = 1;
            if m_IsPlayerMTG ~= m_IsGoldExchange then delta = -1; end -- xor
            -- Update the deal
            if otgDetails.OneTimeGold == m_LastAcceptedGold.OneTimeGold and mtgDetails.MultiTurnGold == m_LastAcceptedGold.MultiTurnGold then
                -- Second time getting the same offer, this is the last offer AI accept, end update.
                table.insert(m_Offers, GetPlayerOfferInDeal(deal, m_PlayerId, otherPlayerId, m_IsPlayerMTG or m_IsGoldExchange));
                DiplomacyManager.CloseSession(sessionId);
                EndMultiTurnGoldUpdate();
                return;
            elseif otgDetails.OneTimeGold == 0 and mtgDetails.MultiTurnGold == 0 then
                -- No gold left in deal, go with the last accepted deal.
                UpdatePlayerGoldInDeal(deal, mtgPlayerId, 0, m_LastAcceptedGold.MultiTurnGold - mtgDetails.MultiTurnGold);
                UpdatePlayerGoldInDeal(deal, otgPlayerId, m_LastAcceptedGold.OneTimeGold - otgDetails.OneTimeGold, 0);
            else
                m_LastAcceptedGold.OneTimeGold = otgDetails.OneTimeGold;
                m_LastAcceptedGold.MultiTurnGold = mtgDetails.MultiTurnGold;
                UpdatePlayerGoldInDeal(deal, otgPlayerId, delta, 0);
            end
        elseif responseAction == DealProposalAction.REJECTED then
            local delta = -1;
            if m_IsPlayerMTG ~= m_IsGoldExchange then delta = 1; end -- xor
            if otgDetails.OneTimeGold + delta >= 0 and otgDetails.OneTimeGold + delta <= otgDetails.MaxOneTimeGold then
                -- Still has extra gold to work with.
                UpdatePlayerGoldInDeal(deal, otgPlayerId, delta, 0);
            else
                -- No one time gold left, check if AI is willing to equalize.
                if m_IsGoldExchange then
                    -- Fail to get gold exchange update.
                    UpdatePlayerGoldInDeal(deal, mtgPlayerId, 0, m_LastAcceptedGold.MultiTurnGold - mtgDetails.MultiTurnGold);
                    UpdatePlayerGoldInDeal(deal, otgPlayerId, m_LastAcceptedGold.OneTimeGold - otgDetails.OneTimeGold, 0);
                    table.insert(m_Offers, GetPlayerOfferInDeal(deal, m_PlayerId, otherPlayerId, m_IsPlayerMTG or m_IsGoldExchange));
                    DiplomacyManager.CloseSession(sessionId);
                    EndMultiTurnGoldUpdate();
                else
                    DealManager.SendWorkingDeal(DealProposalAction.EQUALIZE, m_PlayerId, otherPlayerId);
                    m_AwaitingResponse = { PlayerId = otherPlayerId, DealAction = DealProposalAction.EQUALIZE };
                    StartEqualizeRequestTimer(otherPlayerId, sessionId);
                end
                return;
            end
        end
        SendDealForInspection(deal, otherPlayerId, sessionId);
    elseif lastDealAction == DealProposalAction.EQUALIZE then
        if responseAction == DealProposalAction.EQUALIZE_FAILED then
            -- Equalize failed, go with the last accepted offer.
            local deal = DealManager.GetWorkingDeal(DealDirection.OUTGOING, m_PlayerId, otherPlayerId);
            local mtgDetails = GetPlayerGoldInDeal(deal, mtgPlayerId);
            local otgDetails = GetPlayerGoldInDeal(deal, otgPlayerId);
            UpdatePlayerGoldInDeal(deal, mtgPlayerId, 0, m_LastAcceptedGold.MultiTurnGold - mtgDetails.MultiTurnGold);
            UpdatePlayerGoldInDeal(deal, otgPlayerId, m_LastAcceptedGold.OneTimeGold - otgDetails.OneTimeGold, 0);
            SendDealForInspection(deal, otherPlayerId, sessionId);
        else
            -- Offer equalized, return the deal.
            DealManager.CopyIncomingToOutgoingWorkingDeal(m_PlayerId, otherPlayerId);
            local deal = DealManager.GetWorkingDeal(DealDirection.OUTGOING, m_PlayerId, otherPlayerId);
            table.insert(m_Offers, GetPlayerOfferInDeal(deal, m_PlayerId, otherPlayerId, m_IsPlayerMTG or m_IsGoldExchange));
            DiplomacyManager.CloseSession(sessionId);
            EndMultiTurnGoldUpdate();
            return;
        end
    end
end

function SendDealForInspection(deal, otherPlayerId, sessionId)
    if deal and deal:Validate() == DealValidationResult.VALID then
        DealManager.SendWorkingDeal(DealProposalAction.INSPECT, m_PlayerId, otherPlayerId);
        m_AwaitingResponse = { PlayerId = otherPlayerId, DealAction = DealProposalAction.INSPECT };
    elseif m_IsFetching then
        ContinueToNextAIOfferFetch(otherPlayerId, sessionId);
    elseif m_IsMTGUpdating then
        DiplomacyManager.CloseSession(sessionId);
        EndMultiTurnGoldUpdate();
    end
end

function OnStartAIOfferAccept(playerId:number, otherPlayerId:number)
    if HasJobRunning() then
        -- Add the request to pending queue if there's an existing job.
        local taskArgs = {};
        table.insert(taskArgs, playerId);
        table.insert(taskArgs, otherPlayerId);
        m_PendingJob = {
            Type = JOB_TYPE.ACCEPT,
            Args = taskArgs
        }
        return;
    end
    m_PlayerId = playerId;
    m_IsAccepting = true;
    local deal = DealManager.GetWorkingDeal(DealDirection.OUTGOING, playerId, otherPlayerId);
    m_MyOfferedItemsInDeal = GetPlayerOfferedItemsInDeal(deal, playerId);
    ContinueAIOfferAccept(otherPlayerId);
end

function EndAIOfferAccept()
    m_IsAccepting = false;
    if not ProceedPendingJob() then
        LuaEvents.QD_EndAIOfferAccept(m_MyOfferedItemsInDeal);
    end
end

function ContinueAIOfferAccept(otherPlayerId, lastDealAction:number, responseAction, sessionId, statementSubTypeName)
    if lastDealAction == nil then
        -- Start a session to accept.
        local existSessionId = DiplomacyManager.FindOpenSessionID(m_PlayerId, otherPlayerId);
        if existSessionId == nil then
            DiplomacyManager.RequestSession(m_PlayerId, otherPlayerId, "MAKE_DEAL");
        end
        DealManager.SendWorkingDeal(DealProposalAction.ACCEPTED, m_PlayerId, otherPlayerId);
        m_AwaitingResponse = { PlayerId = otherPlayerId, DealAction = 0 };
    elseif lastDealAction == 0 then
        -- AI will response twice with lastDealAction 0.
        if statementSubTypeName == "NONE" then
            m_AwaitingResponse = { PlayerId = otherPlayerId, DealAction = 0 };
        elseif statementSubTypeName == "HUMAN_ACCEPT_DEAL" then
            -- Second AI response. Acceptance complete, close the session.
            DiplomacyManager.CloseSession(sessionId);
            EndAIOfferAccept();
        end
    end
end

function OnStartAIGoldExchange(playerId:number, aiListToCheck:table, isPlayerOneTimeGold)
    if HasJobRunning() then
        -- Add the request to pending queue if there's an existing job.
        local taskArgs = {};
        table.insert(taskArgs, playerId);
        table.insert(taskArgs, aiListToCheck);
        table.insert(taskArgs, isPlayerOneTimeGold);
        m_PendingJob = {
            Type = JOB_TYPE.EXCHANGE,
            Args = taskArgs
        }
        return;
    end
    m_PlayerId = playerId;
    m_AIListToCheck = aiListToCheck;
    m_IsPlayerOTG = isPlayerOneTimeGold;
    m_AIIndex = 1;
    m_IsExchanging = true;
    m_Offers = {};
    m_MultiTurnGoldFound = false;
    m_LastAcceptedGold = {};
    m_DeltaIndex = 1;
    ContinueAIGoldExchange();
end

function EndAIGoldExchange()
    m_IsExchanging = false;
    if not ProceedPendingJob() then
        LuaEvents.QD_EndAIGoldExchange(m_Offers);
    end
end

function ContinueAIGoldExchange(lastDealAction:number, responseAction, sessionId)
    if m_AIIndex > #m_AIListToCheck then
        EndAIGoldExchange();
        return;
    end

    local otherPlayerId = m_AIListToCheck[m_AIIndex];
    local mtgPlayer = m_PlayerId; -- For multi turn gold right now.
    if m_IsPlayerOTG then mtgPlayer = otherPlayerId; end
    local otgPlayer = otherPlayerId; -- For gold only right now.
    if m_IsPlayerOTG then otgPlayer = m_PlayerId; end
    if lastDealAction == nil then
        -- First start.
        DealManager.ClearWorkingDeal(DealDirection.OUTGOING, m_PlayerId, otherPlayerId);
        local existSessionId = DiplomacyManager.FindOpenSessionID(m_PlayerId, otherPlayerId);
        if existSessionId ~= nil then
            -- If there's an existing session with this AI, proceed to the next step.
            ContinueAIGoldExchange(0, 0, existSessionId);
        else
            DiplomacyManager.RequestSession(m_PlayerId, otherPlayerId, "MAKE_DEAL");
            m_AwaitingResponse = { PlayerId = otherPlayerId, DealAction = 0 };
        end
    elseif lastDealAction == 0 then
        -- Initialized.
        local deal = DealManager.GetWorkingDeal(DealDirection.OUTGOING, m_PlayerId, otherPlayerId);
        if deal then
            m_MultiTurnGoldFound = false;
            m_LastAcceptedGold = {};
            m_DeltaIndex = 1;
            --  Set initial gold in deal.
            local mtgGold = GetPlayerGoldInDeal(deal, mtgPlayer);
            local otgGold = GetPlayerGoldInDeal(deal, otgPlayer);
            local otgLimit = math.min(otgGold.MaxOneTimeGold, mtgGold.MaxMultiTurnGold * 30);
            if otgLimit > 0 then
                UpdatePlayerGoldInDeal(deal, mtgPlayer, 0, math.floor(otgLimit / GOLD_RATIO));
                UpdatePlayerGoldInDeal(deal, otgPlayer, otgLimit, 0); -- Always max out one time gold.
            else
                -- No gold available, move on to next AI.
                DiplomacyManager.CloseSession(sessionId);
                m_AIIndex = m_AIIndex + 1;
                ContinueAIGoldExchange();
                return;
            end
        end
        SendDealForInspection(deal, otherPlayerId, sessionId);
    elseif lastDealAction == DealProposalAction.INSPECT then
        local deal = DealManager.GetWorkingDeal(DealDirection.OUTGOING, m_PlayerId, otherPlayerId);
        local mtgGold = GetPlayerGoldInDeal(deal, mtgPlayer);
        local otgGold = GetPlayerGoldInDeal(deal, otgPlayer);
        if responseAction == DealProposalAction.ACCEPTED then
            local delta = -CHECKING_DELTAS[m_DeltaIndex];
            if m_MultiTurnGoldFound then delta = -delta; end
            if m_IsPlayerOTG then delta = -delta; end
            -- Update the deal
            if not m_MultiTurnGoldFound then
                -- Find best multi turn gold first.
                if mtgGold.MultiTurnGold == m_LastAcceptedGold.MultiTurnGold then
                    -- Second time getting the same offer, multi turn gold found.
                    local adjustDelta = -1;
                    if m_IsPlayerOTG then adjustDelta = -adjustDelta; end
                    if m_DeltaIndex < #CHECKING_DELTAS then
                        -- Reduce checking delta to get more accurate deal.
                        adjustDelta = adjustDelta * (CHECKING_DELTAS[m_DeltaIndex] - CHECKING_DELTAS[m_DeltaIndex + 1]);
                        m_DeltaIndex = m_DeltaIndex + 1;
                        UpdatePlayerGoldInDeal(deal, mtgPlayer, 0, adjustDelta);
                    else
                        m_MultiTurnGoldFound = true;
                        -- If multi turn gold is found, continue with first index that is less than 30.
                        m_DeltaIndex = OTG_CHECK_DELTA_INDEX;
                        if mtgGold.MultiTurnGold == mtgGold.MaxMultiTurnGold then
                            -- Special case for multi turn gold is maxed out. In this case, set one time gold delta index to beginning.
                            m_DeltaIndex = 1;
                        end
                        if m_IsPlayerOTG then
                            m_LastAcceptedGold.MultiTurnGold = mtgGold.MultiTurnGold;
                            -- Reduce one time gold to continue checking.
                            UpdatePlayerGoldInDeal(deal, otgPlayer, -CHECKING_DELTAS[m_DeltaIndex], 0);
                        else
                            -- Set target multi turn gold to be 1 less than the accepted one if player is giving multi turn gold.
                            m_LastAcceptedGold.MultiTurnGold = mtgGold.MultiTurnGold + adjustDelta;
                            UpdatePlayerGoldInDeal(deal, mtgPlayer, 0, adjustDelta);
                        end
                    end
                else
                    m_LastAcceptedGold.MultiTurnGold = mtgGold.MultiTurnGold;
                    UpdatePlayerGoldInDeal(deal, mtgPlayer, 0, delta);
                end
            else
                -- Find best one time gold next.
                if otgGold.OneTimeGold == m_LastAcceptedGold.OneTimeGold then
                    -- Second time getting the same offer, one time gold found.
                    if m_DeltaIndex < #CHECKING_DELTAS then
                        -- Reduce checking delta to get more accurate deal.
                        local adjustDelta = CHECKING_DELTAS[m_DeltaIndex] - CHECKING_DELTAS[m_DeltaIndex + 1];
                        if m_IsPlayerOTG then adjustDelta = -adjustDelta; end
                        UpdatePlayerGoldInDeal(deal, otgPlayer, adjustDelta, 0);
                        m_DeltaIndex = m_DeltaIndex + 1;
                    else
                        -- Final deal found. End update.
                        ContinueToNextAIGoldExchange(otherPlayerId, sessionId);
                        return;
                    end
                else
                    m_LastAcceptedGold.OneTimeGold = otgGold.OneTimeGold;
                    UpdatePlayerGoldInDeal(deal, otgPlayer, delta, 0);
                end
            end
        elseif responseAction == DealProposalAction.REJECTED then
            local delta = CHECKING_DELTAS[m_DeltaIndex];
            if m_MultiTurnGoldFound then delta = -delta; end
            if m_IsPlayerOTG then delta = -delta; end
            if not m_MultiTurnGoldFound then
                if mtgGold.MultiTurnGold + delta >= 0 and mtgGold.MultiTurnGold + delta <= mtgGold.MaxMultiTurnGold then
                    -- Still has extra gold to work with.
                    UpdatePlayerGoldInDeal(deal, mtgPlayer, 0, delta);
                    if mtgGold.MultiTurnGold + delta == m_LastAcceptedGold.MultiTurnGold then
                        -- We expect an accept from AI, simply shortcut the flow and not sending the deal to AI.
                        ContinueAIGoldExchange(DealProposalAction.INSPECT, DealProposalAction.ACCEPTED, sessionId);
                        return;
                    end
                else
                    if m_DeltaIndex < #CHECKING_DELTAS then
                        -- Reach the max or min with higher value as delta, reduce to lower value and continue the check.
                        m_DeltaIndex = m_DeltaIndex + 1;
                        local adjustDelta = CHECKING_DELTAS[m_DeltaIndex];
                        if m_IsPlayerOTG then adjustDelta = -adjustDelta; end
                        UpdatePlayerGoldInDeal(deal, mtgPlayer, 0, adjustDelta);
                    else
                        -- Multi turn gold has reached the maximum. Set to maxs.
                        -- TODO: Might need to think about how to improve the performance here.
                        m_DeltaIndex = 1; -- Start from scratch for one time gold, since max multi turn gold was rejected.
                        m_MultiTurnGoldFound = true;
                        m_LastAcceptedGold.MultiTurnGold = mtgGold.MaxMultiTurnGold;
                        -- Reduce one time gold to continue checking.
                        local adjustDelta = -CHECKING_DELTAS[m_DeltaIndex];
                        if m_IsPlayerOTG then adjustDelta = -adjustDelta; end
                        UpdatePlayerGoldInDeal(deal, otgPlayer, adjustDelta, 0);
                    end
                end
            else
                if otgGold.OneTimeGold + delta >= 0 and otgGold.OneTimeGold + delta <= otgGold.MaxOneTimeGold then
                    -- Still has extra gold to work with.
                    UpdatePlayerGoldInDeal(deal, otgPlayer, delta, 0);
                    if otgGold.OneTimeGold + delta == m_LastAcceptedGold.OneTimeGold then
                        -- We expect an accept from AI, simply shortcut the flow and not sending the deal to AI.
                        ContinueAIGoldExchange(DealProposalAction.INSPECT, DealProposalAction.ACCEPTED, sessionId);
                        return;
                    end
                else
                    if m_DeltaIndex < #CHECKING_DELTAS then
                        -- Reduce checking delta to get more accurate deal.
                        m_DeltaIndex = m_DeltaIndex + 1;
                        local adjustDelta = -CHECKING_DELTAS[m_DeltaIndex];
                        if m_IsPlayerOTG then adjustDelta = -adjustDelta; end
                        UpdatePlayerGoldInDeal(deal, otgPlayer, adjustDelta, 0);
                    else
                        -- Not able to find a possible deal, skipping to next AI.
                        -- TODO: Might need to think if there are other scenarios.
                        DiplomacyManager.CloseSession(sessionId);
                        m_AIIndex = m_AIIndex + 1;
                        ContinueAIGoldExchange();
                        return;
                    end
                end
            end
        end
        SendDealForInspection(deal, otherPlayerId, sessionId);
    end
end

function ContinueToNextAIGoldExchange(otherPlayerId, sessionId)
    local deal = DealManager.GetWorkingDeal(DealDirection.OUTGOING, m_PlayerId, otherPlayerId);
    if deal then
        local offer = GetPlayerOfferInDeal(deal, m_PlayerId, otherPlayerId, true);
        if offer ~= nil and table.count(offer.OfferedItems) > 0 then
            table.insert(m_Offers, offer);
        end
    end
    -- Close the session with the current AI before moving to the next AI.
    DiplomacyManager.CloseSession(sessionId);
    -- Move to the next AI.
    m_AIIndex = m_AIIndex + 1;
    ContinueAIGoldExchange();
end

function HasJobRunning()
    return m_IsFetching or m_IsAccepting or m_IsExchanging or m_IsMTGUpdating;
end

function ProceedPendingJob()
    if m_PendingJob ~= nil then
        local type = m_PendingJob.Type;
        local args = m_PendingJob.Args;
        m_PendingJob = nil;
        if type == JOB_TYPE.FETCH then
            LuaEvents.QD_StartAIOfferFetch(unpack(args));
        elseif type == JOB_TYPE.ACCEPT then
            LuaEvents.QD_StartAIOfferAccept(unpack(args));
        elseif type == JOB_TYPE.EXCHANGE then
            LuaEvents.QD_StartAIGoldExchange(unpack(args));
        elseif type == JOB_TYPE.MTGUPDATE then
            LuaEvents.QD_StartMultiTurnGoldUpdate(unpack(args));
        end
        return true;
    end
    return false;
end

function UpdatePlayerGoldInDeal(deal, goldPlayerId, oneTimeGoldDelta, multiTurnGoldDelta)
    local dealItems = deal:FindItemsByType(DealItemTypes.GOLD, DealItemSubTypes.NONE, goldPlayerId);
    local oneTimeGold = -1;
    local multiTurnGold = -1;
    if dealItems ~= nil then
        for i, dealItem in ipairs(dealItems) do
            if dealItem:GetDuration() == 0 then
                oneTimeGold = dealItem:GetAmount() + oneTimeGoldDelta;
                oneTimeGold = math.max(oneTimeGold, 0);
                oneTimeGold = math.min(oneTimeGold, dealItem:GetMaxAmount());
                if oneTimeGold > 0 then
                    dealItem:SetAmount(oneTimeGold);
                else
                    deal:RemoveItemByID(dealItem:GetID());
                end
            else
                multiTurnGold = dealItem:GetAmount() + multiTurnGoldDelta;
                multiTurnGold = math.max(multiTurnGold, 0);
                multiTurnGold = math.min(multiTurnGold, dealItem:GetMaxAmount());
                if multiTurnGold > 0 then
                    dealItem:SetAmount(multiTurnGold);
                else
                    deal:RemoveItemByID(dealItem:GetID());
                end
            end
        end
    end
    if oneTimeGold == -1 then
        -- Doesn't exist yet, add new item.
        dealItem = deal:AddItemOfType(DealItemTypes.GOLD, goldPlayerId);
        if dealItem ~= nil then
            dealItem:SetDuration(0);
            oneTimeGold = oneTimeGoldDelta;
            oneTimeGold = math.max(oneTimeGold, 0);
            oneTimeGold = math.min(oneTimeGold, dealItem:GetMaxAmount());
            if oneTimeGold > 0 then
                dealItem:SetAmount(oneTimeGold);
            else
                deal:RemoveItemByID(dealItem:GetID());
            end
        end
    end
    if multiTurnGold == -1 then
        -- Doesn't exist yet, add new item.
        dealItem = deal:AddItemOfType(DealItemTypes.GOLD, goldPlayerId);
        if dealItem ~= nil then
            dealItem:SetDuration(30);
            multiTurnGold = multiTurnGoldDelta;
            multiTurnGold = math.max(multiTurnGold, 0);
            multiTurnGold = math.min(multiTurnGold, dealItem:GetMaxAmount());
            if multiTurnGold > 0 then
                dealItem:SetAmount(multiTurnGold);
            else
                deal:RemoveItemByID(dealItem:GetID());
            end
        end
    end
end

function GetPlayerOfferedItemsInDeal(deal, playerId)
    local items = {};
    if deal then
        for dealItem in deal:Items() do
            if dealItem:GetFromPlayerID() == playerId then
                local dealType = dealItem:GetType();
                local item;
                if dealType == DealItemTypes.AGREEMENTS then
                    item = {
                        Id = dealItem:GetSubType(),
                        Type = dealType,
                        Amount = 1,
                        Duration = dealItem:GetDuration()
                    };
                elseif dealType == DealItemTypes.GREATWORK then
                    item = {
                        Id = dealItem:GetValueType(),
                        DescId = dealItem:GetSubType(),
                        Type = dealType,
                        Amount = 1,
                        Duration = dealItem:GetDuration()
                    };
                else
                    item = {
                        Id = dealItem:GetValueType(),
                        Type = dealType,
                        Amount = dealItem:GetAmount(),
                        Duration = dealItem:GetDuration()
                    };
                end
                table.insert(items, item);
            end
        end
    end
    return items;
end

function GetPlayerOfferInDeal(deal, playerId, otherPlayerId, isAISelling)
    local goldPlayerId;
    local offeredItems;
    if isAISelling then
        goldPlayerId = playerId;
        offeredItems = GetPlayerOfferedItemsInDeal(deal, otherPlayerId);
    else
        goldPlayerId = otherPlayerId;
        offeredItems = GetPlayerOfferedItemsInDeal(deal, playerId);
    end
    local goldDetails = GetPlayerGoldInDeal(deal, goldPlayerId);
    local equalized = true;
    if goldPlayerId == otherPlayerId then
        -- Only need to check equalization if AI is paying. If AI is paying with all their gold, it might not be equalized.
        equalized = not (goldDetails.OneTimeGold == goldDetails.MaxOneTimeGold and goldDetails.MultiTurnGold == goldDetails.MaxMultiTurnGold);
    end
    local offer = {
        PlayerId = otherPlayerId,
        OneTimeGold = goldDetails.OneTimeGold,
        MultiTurnGold = goldDetails.MultiTurnGold,
        Total = goldDetails.OneTimeGold + goldDetails.MultiTurnGold * 30,
        OfferedItems = offeredItems,
        HasNonGoldItem = goldDetails.HasNonGoldItem,
        Equalized = equalized,
    };
    if offer.Total > 0 or offer.HasNonGoldItem then
        return offer;
    end
    return nil;
end

function AddHumanOfferedItemsToDeal(deal, otherPlayerId)
    for dealType, dealItems in pairs(m_MyOfferedItems) do
        for id, item in pairs(dealItems) do
            local addAmount = item.Amount;
            if dealType == DealItemTypes.RESOURCES then
                -- Get the given player's need amount for this item.
                local amountNeeded = ResourceAmountNeeded(otherPlayerId, id, false);
                addAmount = math.min(amountNeeded, item.Amount);
            elseif dealType == DealItemTypes.AGREEMENTS then
                -- Clear the add amount by default.
                addAmount = 0;
                local possibleAgreements = DealManager.GetPossibleDealItems(m_PlayerId, otherPlayerId, DealItemTypes.AGREEMENTS, deal);
                if possibleAgreements then
                    for i, entry in ipairs(possibleAgreements) do
                        if entry.SubType == id then
                            addAmount = 1;
                        end
                    end
                end
            end
            if addAmount > 0 then
                local dealItem = deal:AddItemOfType(dealType, m_PlayerId);
                if dealItem then
                    if dealType == DealItemTypes.AGREEMENTS then
                        dealItem:SetSubType(id);
                    elseif dealType == DealItemTypes.GREATWORK then
                        dealItem:SetValueType(id);
                        dealItem:SetSubType(item.DescId);
                    else
                        dealItem:SetValueType(id);
                        dealItem:SetAmount(addAmount);
                    end
                    dealItem:SetDuration(item.Duration);
                    -- Remove the deal item if it is not valid.
                    if not dealItem:IsValid() then
                        deal:RemoveItemByID(dealItem:GetID());
                    end
                end
            end
        end
    end
end

function AddAIOfferedItemsToDeal(deal, otherPlayerId)
    if m_AISellingType == ITEM_TYPE.LUXURY_RESOURCES or m_AISellingType == ITEM_TYPE.STRATEGIC_RESOURCES then
        local possibleResources = DealManager.GetPossibleDealItems(otherPlayerId, m_PlayerId, DealItemTypes.RESOURCES, deal);
        if possibleResources ~= nil then
            for i, entry in ipairs(possibleResources) do
                local index = entry.ForType;
                if HasExtraResource(otherPlayerId, index, entry.MaxAmount) then
                    if m_AISellingSubType == nil or index == m_AISellingSubType then
                        local resourceDesc = GameInfo.Resources[index];
                        local amountNeeded = ResourceAmountNeeded(m_PlayerId, index, true);
                        if resourceDesc and amountNeeded > 0 then
                            local amount = 0;
                            local duration = 30;
                            if m_AISellingType == ITEM_TYPE.STRATEGIC_RESOURCES and resourceDesc.ResourceClassType == "RESOURCECLASS_STRATEGIC" then
                                if not g_IsXP2Active then
                                    amount = 1;
                                elseif entry.MaxAmount >= GetStrategicResourceThreshold(index) then
                                    -- In xp2, AI will only sell strategic resources when it has more than 40 copies.
                                    amount = math.min(entry.MaxAmount, amountNeeded);
                                    duration = 0;
                                end
                            elseif m_AISellingType == ITEM_TYPE.LUXURY_RESOURCES and resourceDesc.ResourceClassType == "RESOURCECLASS_LUXURY" then
                                amount = 1;
                            end
                            -- Add the item if amount needed is larger than 0.
                            if amount > 0 then
                                local dealItem = deal:AddItemOfType(DealItemTypes.RESOURCES, otherPlayerId);
                                if dealItem then
                                    dealItem:SetValueType(index);
                                    dealItem:SetAmount(amount);
                                    dealItem:SetDuration(duration);
                                end
                            end
                        end
                    end
                end
            end
        end
    elseif g_IsXP2Active and m_AISellingType == ITEM_TYPE.FAVOR then
        local possibleItems = DealManager.GetPossibleDealItems(otherPlayerId, m_PlayerId, DealItemTypes.FAVOR, deal);
        if possibleItems ~= nil then
            for i, entry in ipairs(possibleItems) do
                local amount = math.min(DIPLOMATIC_FAVOR_THRESHOLD, entry.MaxAmount);
                if amount > 0 then
                    local dealItem = deal:AddItemOfType(DealItemTypes.FAVOR, otherPlayerId);
                    if dealItem then
                        dealItem:SetValueType(DIPLOMATIC_FAVOR_INDEX);
                        dealItem:SetAmount(amount);
                        dealItem:SetDuration(0);
                    end
                end
            end
        end
    elseif m_AISellingType == ITEM_TYPE.GREAT_WORKS and m_AISellingSubType ~= nil then
        local possibleItems = DealManager.GetPossibleDealItems(otherPlayerId, m_PlayerId, DealItemTypes.GREATWORK, deal);
        if possibleItems ~= nil then
            for i, entry in ipairs(possibleItems) do
                local objectType = GameInfo.GreatWorks[entry.ForTypeDescriptionID].GreatWorkObjectType;
                if objectType == GameInfo.GreatWorkObjectTypes[m_AISellingSubType].GreatWorkObjectType then
                    local dealItem = deal:AddItemOfType(DealItemTypes.GREATWORK, otherPlayerId);
                    if dealItem then
                        dealItem:SetValueType(entry.ForType);
                        dealItem:SetAmount(1);
                        dealItem:SetDuration(0);
                        dealItem:SetSubType(entry.ForTypeDescriptionID);
                        -- Remove the deal item if it is not valid.
                        if not dealItem:IsValid() then
                            deal:RemoveItemByID(dealItem:GetID());
                        else
                            -- Only add one item at a time.
                            break;
                        end
                    end
                end
            end
        end
    end
end

function AddAllAIGoldToDeal(deal, otherPlayerId)
    local goldAdded = false;
    -- Remove all gold first.
    local dealItems = deal:FindItemsByType(DealItemTypes.GOLD, DealItemSubTypes.NONE, otherPlayerId);
    if dealItems ~= nil then
        for _, dealItem in ipairs(dealItems) do
            deal:RemoveItemByID(dealItem:GetID());
        end
    end
    -- Add all one time gold.
    local oneTimeGoldDealItem = deal:AddItemOfType(DealItemTypes.GOLD, otherPlayerId);
    if oneTimeGoldDealItem ~= nil then
        oneTimeGoldDealItem:SetDuration(0);
        local addAmount = oneTimeGoldDealItem:GetMaxAmount();
        if addAmount > 0 then
            oneTimeGoldDealItem:SetAmount(addAmount);
            goldAdded = true;
        else
            deal:RemoveItemByID(oneTimeGoldDealItem:GetID());
        end
    end
    -- Add all multi turn gold.
    local multiTurnGoldDealItem = deal:AddItemOfType(DealItemTypes.GOLD, otherPlayerId);
    if multiTurnGoldDealItem ~= nil then
        multiTurnGoldDealItem:SetDuration(30);
        local addAmount = multiTurnGoldDealItem:GetMaxAmount();
        if addAmount > 0 then
            multiTurnGoldDealItem:SetAmount(addAmount);
            goldAdded = true;
        else
            deal:RemoveItemByID(multiTurnGoldDealItem:GetID());
        end
    end
    return goldAdded;
end

function StartEqualizeRequestTimer(otherPlayerId, sessionId)
    Controls.RequestTimer:SetToBeginning();
    Controls.RequestTimer:RegisterEndCallback(
        function()
            -- When RequestTimer animation ends, it means the previous request takes a much longer time or AI is not responding.
            -- Perform a fake diplomacy response instead. i.e. Equalize failed.
            OnDiplomacyStatement(otherPlayerId, m_PlayerId, {
                SessionID = sessionId,
                DealAction = DealProposalAction.EQUALIZE_FAILED,
                RespondingToDealAction = DealProposalAction.EQUALIZE,
                StatementType = -2065048438 -- Make Deal
            });
        end
    );
    Controls.RequestTimer:Play();
end

function FinishPopupClose(sessionIdToSkip)
    -- Close all diplomacy session and notify popup closed.
    CloseAllDiplomacySessions(sessionIdToSkip);
    LuaEvents.QDDealPopup_Closed();
    m_PopupCloseRequested = false;
end

function OnPopupCloseRequested()
    m_PopupCloseRequested = true;
    if m_AwaitingResponse == nil then
        -- Not awaiting responses, finish popup closing.
        FinishPopupClose();
    end
end

function OnSurpriseSession(sessionId)
    m_IsFetching = false;
    m_IsAccepting = false;
    m_IsMTGUpdating = false;
    m_AwaitingResponse = nil;
    FinishPopupClose(sessionId);
end

function QD_Initialize()
    Events.DiplomacyStatement.Add(OnDiplomacyStatement);
    LuaEvents.QD_StartAIOfferAccept.Add(OnStartAIOfferAccept);
    LuaEvents.QD_StartAIOfferFetch.Add(OnStartAIOfferFetch);
    LuaEvents.QD_StartAIGoldExchange.Add(OnStartAIGoldExchange);
    LuaEvents.QD_StartMultiTurnGoldUpdate.Add(OnStartMultiTurnGoldUpdate);
    LuaEvents.QDDealPopup_CloseRequest.Add(OnPopupCloseRequested);
    LuaEvents.QD_OnSurpriseSession.Add(OnSurpriseSession);
end

QD_Initialize();
