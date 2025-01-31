-- Support_PurProd
-- Author: Administrator
-- DateCreated: 2024/3/2 12:54:47
--------------------------------------------------------------

function PlayerHasLeaderTrait(playerID, sTraitType)
	local config = PlayerConfigurations[playerID]
	if config ~= nil then
		local sLeaderType = config:GetLeaderTypeName()
	    for tRow in GameInfo.LeaderTraits() do
			if tRow.LeaderType == sLeaderType and tRow.TraitType == sTraitType then 
				print("Has_LA:"..sTraitType)
				return true
			end
		end
	end
    return false
end

-- ===========================================================================

function PlayerHasCivTrait(playerID, sTraitType)
	local config = PlayerConfigurations[playerID]
	if config ~= nil then
		local sCivType = config:GetCivilizationTypeName()
	    for tRow in GameInfo.CivilizationTraits() do
			if tRow.CivilizationType == sCivType and tRow.TraitType == sTraitType then 
				print("Has_UA:"..sTraitType)
				return true
			end
		end
	end
    return false
end

-- ===========================================================================