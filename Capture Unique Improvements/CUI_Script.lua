local m_improvements = {};
local m_uniques = {};
local m_settleState = false;
local m_removeState = false;
local m_debug = false;
local m_removeImprovement = GameInfo.UnitOperations["UNITOPERATION_REMOVE_IMPROVEMENT"].Hash;
local m_x, m_y = Map.GetGridSize();

function InitializeImprovements()
	for ix = 0, m_x - 1 do
		for iy = 0, m_y - 1 do
			table.insert(m_improvements, {});
		end
	end
end

function AddImprovementToTable(iX, iY, eImprovement, playerID)
	local index = m_x * iY + iX;
	local row = {};
	row.x = iX;
	row.y = iY;
	row.improvement = eImprovement;
	row.player = playerID;
	local plot = Map.GetPlot(iX, iY);
	if plot ~= nil then
		row.pillaged = plot:IsImprovementPillaged();
	else
		DebugPrint("Error no plot at "..tostring(iX)..", "..tostring(iY));
		row.pillaged = false;
	end
	m_improvements[index] = row;
end

function RemoveImprovementFromTable(iX, iY)
	local index = m_x * iY + iX;
	-- If during a player's turn and the improvement was not removed by a builder,
	-- then it must have been removed by a district/wonder placement or by a city
	-- transfer event.
	if not m_removeState then
		DebugPrint("Improvement removed not by builder");
		table.insert(m_uniques, m_improvements[index]);
	end
	-- If an improvement was removed by a builder, reset state
	if m_removeState then
		m_removeState = false;
	end
	-- Always remove the improvement from the master table
	m_improvements[index] = {};
end

function RebuildUniques(playerID, cityID)
	if m_settleState == true then
		return;
	end
	-- Loop through our uniques and add them into the city
	DebugPrint("Rebuilding improvements...");
	for _, row in ipairs(m_uniques) do
		local plot = Map.GetPlot(row.x, row.y);
		local improvement = row.improvement;
		DebugPrint("Attempting to place improvement "..tostring(improvement).." at "..tostring(row.x)..", "..tostring(row.y));
		-- Ensure no improvement already exists here
		if CanHaveImprovement(plot, cityID) then
			DebugPrint("    Success!");
			local pillaged = row.pillaged;
			DebugPrint("      Pillaged! = "..tostring(pillaged));
			ImprovementBuilder.SetImprovementType(plot, improvement, playerID);
			ImprovementBuilder.SetImprovementPillaged(plot, pillaged);
		else
			DebugPrint("    Failed!");
		end
	end
	ClearUniques();
end

function CanHaveImprovement(plot, cityID)
	-- Input plot/city exists?
	if plot == nil or cityID == nil then
		return false;
	end
	-- Improvement already exists?
	if plot:GetImprovementType() ~= -1 then
		return false;
	end
	-- Plot's city exists?
	local city = Cities.GetPlotWorkingCity(plot);
	if city == nil then
		return false;
	end
	-- Plot's city is input city?
	if city:GetID() ~= cityID then
		return false;
	end
	-- Plot has district/wonder?
	if plot:GetDistrictType() ~= -1 then
		return false;
	end
	-- Else true
	return true;
end

-- Track pillaging
function ChangeImprovementStatus(iX, iY, improvementType, improvementOwner, resource, isPillaged, isWorked)
	local index = m_x * iY + iX;
	local row = m_improvements[index];
	row.pillaged = isPillaged == 1;
	m_improvements[index] = row;
end

function TrackRemoveImprovement(ownerID, unitID, operationID)
	if operationID == m_removeImprovement then
		m_removeState = true;
	end
end

function ClearUniques()
	DebugPrint("Uniques cleared");
	m_uniques = {};
end

function SettleStateOn()
	DebugPrint("City added - m_settleState = true");
	m_settleState = true;
end

function SettleStateOff()
	DebugPrint("City init/load screen close - m_settleState = false");
	m_settleState = false;
end

function DebugPrint(text)
	if m_debug then
		print(text);
	end
end

function DebugToggle()
	m_debug = not m_debug;
end

function Initialize()
	DebugPrint("INITIALIZE");
	InitializeImprovements();
	
	-- Functionality
	Events.CityAddedToMap.Add(SettleStateOn);
	Events.CityInitialized.Add(SettleStateOff);
	Events.LoadScreenClose.Add(SettleStateOff);
	
	Events.ImprovementAddedToMap.Add(AddImprovementToTable);
	Events.ImprovementRemovedFromMap.Add(RemoveImprovementFromTable);
	Events.ImprovementChanged.Add(ChangeImprovementStatus);
	
	Events.CityTransfered.Add(RebuildUniques);
	Events.CityTileOwnershipChanged.Add(RebuildUniques);
	
	Events.UnitOperationStarted.Add(TrackRemoveImprovement);
	Events.PlayerTurnActivated.Add(ClearUniques);
end

Initialize();