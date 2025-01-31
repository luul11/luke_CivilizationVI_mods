-- LuaScript1
-- Author: Administrator
-- DateCreated: 9/11/2024 11:21:12 PM
--------------------------------------------------------------
--Game.AddWorldViewText(0, TypeName ,10, 9)
--TryAddExp(pCity,DISTRICT_ENCAMPMENT_INDEX,playerId)
--TryAddExp(pCity,DISTRICT_HARBOR_INDEX,playerId)
--TryAddExp(pCity,DISTRICT_DISTRICT_AERODROME,playerId)

--function TryAddExp(pCity,BUILD_INDEX,playerId)
--	if pCity:GetDistricts():HasDistrict(BUILD_INDEX) then
--		local x,y = pCity:GetDistricts():GetDistrictLocation(BUILD_INDEX)
--		local plot = Map.GetPlotIndex(x,y)
--		for loop, unit in ipairs(Units.GetUnitsInPlot(plot)) do
--			if(unit ~= nil) then
--				local iPlayer = unit:GetOwner()
--				if iPlayer == playerId then
--					unit:GetExperience():ChangeExperience(2)
--				end
--			end
--		end
--	end
--end


function UniqueDistrictFinder (iPlayerID, sDistrict)
    local UniqueDistrictIDs = {}
    for _,item in ipairs(GameInfo.Districts[sDistrict].ReplacedByCollection) do
        local UniqieDistrictType = item.CivUniqueDistrictType
        if HasTrait (iPlayerID, GameInfo.Districts[UniqieDistrictType].TraitType) then
            table.insert(UniqueDistrictIDs, GameInfo.Districts[UniqieDistrictType].Index)
        end
    end
    if #UniqueDistrictIDs > 0 then
        return UniqueDistrictIDs[Game.GetRandNum(#UniqueDistrictIDs)+1]
    else
        return GameInfo.Districts[sDistrict].Index
    end
end

function HasTrait(playerId:number , traitName:string)

	if playerId == nil then playerId = Game.GetLocalPlayer(); end
	if playerId == -1 then return false; end	-- Autoplay.
		
	local config :table = PlayerConfigurations[playerId];
	if(config ~= nil) then
		local leaderType:string = config:GetLeaderTypeName();
		local civType	:string = config:GetCivilizationTypeName();
		if leaderType then
			for row in GameInfo.CivilizationTraits() do
				if row.TraitType==traitName then
					for row2 in GameInfo.CivilizationLeaders() do
						if row.CivilizationType == row2.CivilizationType and row2.LeaderType == leaderType then
							return true;
						end
					end
				end
			end
		end
	end
	return false;
end

function OnTurnBegin()
	for _, playerId in ipairs(PlayerManager.GetWasEverAliveMajorIDs()) do
		local pPlayer = Players[playerId]
		if pPlayer then
			--兵营增加经验 DISTRICT_ENCAMPMENT军营 DISTRICT_HARBOR港口 DISTRICT_AERODROME航空港
			local DISTRICT_ENCAMPMENT_INDEX =UniqueDistrictFinder(playerId,"DISTRICT_ENCAMPMENT")-- GameInfo.Districts["DISTRICT_ENCAMPMENT"].Index
			local DISTRICT_HARBOR_INDEX = UniqueDistrictFinder(playerId,"DISTRICT_HARBOR")--GameInfo.Districts["DISTRICT_HARBOR"].Index 
			local DISTRICT_DISTRICT_AERODROME = UniqueDistrictFinder(playerId,"DISTRICT_AERODROME")
			for i, unit in pPlayer:GetUnits():Members() do
				local plot = Map.GetPlot(unit:GetX(), unit:GetY())
				if (plot ~= nil) then
					local iPlayer = plot:GetOwner()
					if iPlayer == playerId then
						local DistrictType = plot:GetDistrictType()
						if DistrictType and DistrictType ~= -1 then
							local CanAdd = false
							if DistrictType == DISTRICT_ENCAMPMENT_INDEX then CanAdd = true end
							if DistrictType == DISTRICT_HARBOR_INDEX then CanAdd = true end
							if DistrictType == DISTRICT_DISTRICT_AERODROME then CanAdd = true end
							if CanAdd then
								unit:GetExperience():ChangeExperience(2)
							end
						end
					end
				end
			end
		end
	end
end

--OnTurnBegin()

local function Initialize()
	Events.TurnBegin.Add(OnTurnBegin)
end
Initialize();