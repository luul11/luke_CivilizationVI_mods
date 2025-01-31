-- Created by FinalFreak16
-- Last Update - 26/03/23
-- Changes:
--   [] Reworked Mod to use function overrides. Should improve compatibility with other mods and if base files change.
--   [] Future Civic Completion no longer prompts reminder.

include("ActionPanel_Expansion1")

-- ===========================================================================
--	CONSTANTS
-- ===========================================================================
local reminderTitle 				:string = Locale.Lookup("LOC_FF16_NEWPOLICY_TITLE");
local reminderDesc 					:string = Locale.Lookup("LOC_FF16_NEWPOLICY_DESC");
local reminderChange 				:string = Locale.Lookup("LOC_FF16_NEWPOLICY_CHANGE");
local reminderContinue 				:string = Locale.Lookup("LOC_FF16_NEWPOLICY_CONTINUE");
													  
-- ===============================================================================================
--	Override for - Attempt to end the turn or execute the most current blocking notification
-- ===============================================================================================
function DoEndTurn( optionalNewBlocker:number )

	local pPlayer = Players[Game.GetLocalPlayer()];
	if (pPlayer == nil) then
		return;
	end
	
	--FF16 - Get Culture info.
	local kCulture:table	= pPlayer:GetCulture();
	--FF16 - Get Civic unlocked this turn, if any. Used later to not prompt on Future Civic Completion.
	local lastCivicInfo = GameInfo.Civics[kCulture:GetCivicCompletedThisTurn()];
	if(lastCivicInfo == nil) then lastCivicInfo = "None"; end
	--print(lastCivicInfo);
	--print("New Policy Cards?", kCulture:CivicCompletedThisTurn());
	--print("Cards have been changed?", kCulture:PolicyChangeMade());

	-- If the player can unready their turn, request that.
	-- CanUnreadyTurn() only checks the gamecore state. IsTurnTimerElapsed() is also required to ensure the local player still has turn time remaining.
	if pPlayer:CanUnreadyTurn()
		and not UI.IsTurnTimerElapsed(Game.GetLocalPlayer()) then
		UI.RequestAction(ActionTypes.ACTION_UNREADYTURN);	
		return;
	end

	if UI.IsProcessingMessages() then
		print("ActionPanel:DoEndTurn() The game is busy processing messages");
		return;
	end

	-- If not in selection mode; reset mode before performing the action.
	if UI.GetInterfaceMode() ~= InterfaceModeTypes.SELECTION then
		UI.SetInterfaceMode(InterfaceModeTypes.SELECTION);
	end

	-- Make sure if an active blocker is not set, to do one more check from the engine/authority.
	if optionalNewBlocker ~= nil then
		m_activeBlockerId = optionalNewBlocker;
	else
		m_activeBlockerId = NotificationManager.GetFirstEndTurnBlocking(Game.GetLocalPlayer());
	end
	
	if m_activeBlockerId == EndTurnBlockingTypes.NO_ENDTURN_BLOCKING then
		if (CheckUnitsHaveMovesState()) then
			UI.SelectNextReadyUnit();
		elseif(CheckCityRangeAttackState()) then
			local attackCity = pPlayer:GetCities():GetFirstRangedAttackCity();
			if(attackCity ~= nil) then
				UI.SelectCity(attackCity);
				UI.SetInterfaceMode(InterfaceModeTypes.CITY_RANGE_ATTACK);
			else
				UI.DataError( "Unable to find selectable attack city while in CheckCityRangeAttackState()" );
			end

		--========================================================================================================================================--
		--FF16~ Add a reminder about new policies being unlocked. 
		elseif(kCulture:CivicCompletedThisTurn() and not kCulture:PolicyChangeMade() and Game.GetCurrentGameTurn() ~= 1 and lastCivicInfo.CivicType ~= "CIVIC_FUTURE_CIVIC") then	  
			local m_kPopupDialog:table = PopupDialogInGame:new( "ContinueWithoutChangingPoliciesPrompt" );
			m_kPopupDialog:AddTitle(reminderTitle);
			m_kPopupDialog:AddText(reminderDesc);
			m_kPopupDialog:AddCancelButton(reminderChange, function() 
				LuaEvents.NotificationPanel_GovernmentOpenPolicies();
			end );
			m_kPopupDialog:AddConfirmButton(reminderContinue, function()
				UI.RequestAction(ActionTypes.ACTION_ENDTURN);		
				UI.PlaySound("Stop_Unit_Movement_Master");
			end );
			m_kPopupDialog:Open();		
		else
			UI.RequestAction(ActionTypes.ACTION_ENDTURN);		
			UI.PlaySound("Stop_Unit_Movement_Master");
		end
		--========================================================================================================================================--

	elseif (   m_activeBlockerId == EndTurnBlockingTypes.ENDTURN_BLOCKING_STACKED_UNITS
			or m_activeBlockerId == EndTurnBlockingTypes.ENDTURN_BLOCKING_UNIT_NEEDS_ORDERS
			or m_activeBlockerId == EndTurnBlockingTypes.ENDTURN_BLOCKING_UNITS)	then
		UI.SelectNextReadyUnit();
	else		

		-- generic turn blocker, trigger the notification associated with the turn blocker.
		local pNotification :table = NotificationManager.FindEndTurnBlocking(m_activeBlockerId, Game.GetLocalPlayer());
		
		if pNotification == nil then
			-- Notification is missing.  Use fallback behavior.
			if not UI.CanEndTurn() then
				UI.DataError("The UI thinks that we can't end turn, but the notification system disagrees.");
				return;
			end				
			UI.RequestAction(ActionTypes.ACTION_ENDTURN);		
			return;
		end

		-- Raise the event across the UI which may be listening for this particular notification.
		LuaEvents.ActionPanel_ActivateNotification( pNotification );
	end
end