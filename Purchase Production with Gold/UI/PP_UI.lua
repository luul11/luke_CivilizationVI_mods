include("Support_PP")
include( "PopupDialog" )
-- Modified from MyGO!!!!! Civilization Mod by Huan

-- =========================== City Panel Gold Purchase Production Button ===========================

local Utils                             = ExposedMembers.PP_Utils
local PP_Trait                          = GameInfo.Traits["TRAIT_GOLD_PURCHASE"].TraitType
local goldPPTitle               :string = Locale.Lookup("LOC_HUAN_PP_POPUP_1_TITLE")
local goldPPDesc                :string = Locale.Lookup("LOC_HUAN_PP_POPUP_1_DESCRIPTION", 0, 0)
local goldPPCancel              :string = Locale.Lookup("LOC_HUAN_PP_POPUP_1_CANCEL")
local goldPPApply               :string = Locale.Lookup("LOC_HUAN_PP_POPUP_1_APPLY")
local gameSpeed                         = GameConfiguration.GetGameSpeedType()
local percentage                        = GameInfo.GlobalParameters["HUAN_GOLD_PURCHASE_PRODUCTION_EFFICIENCY"].Value
local iSpeedCostMultiplier              = GameInfo.GameSpeeds[gameSpeed].CostMultiplier * 0.01

-- local timing                            = 10
-- function PP_Timer()
--     timing = timing - 1
--     if timing == 0 then
--         local playerID = Game.GetLocalPlayer();
--         local pPlayer = Players[playerID];
--         local iStarNum = pPlayer:GetProperty("starnum")
--         local iResStarNumCurrent = pPlayer:GetResources():GetResourceAmount(star)
--         if (iStarNum > iResStarNumCurrent) then
--             ExposedMembers.Huan_PP.MyGO_SetResource(playerID, star, iStarNum - iResStarNumCurrent)
--         end
--         Events.GameCoreEventPublishComplete.Remove(PP_Timer)
--         timing = 10
--     end
-- end

function PP_OnCityFocusChanged(playerID, cityID, iI, iJ, iK, isSelected, isEditable)
    --print("City Focus Changed")
    local pPlayer = Players[playerID]
    if (pPlayer == nil) then return end
    -- local pCity = CityManager.GetCity(playerID, cityID)
    -- if (PlayerHasLeaderTrait(playerID, PP_Trait) == false or pPlayer:IsAI()) then
    --     print("Has no trait")
    --     Controls.GoldPurchaseButton:SetHide(true)
    --     return
    -- else
    --     local gold = pPlayer:GetTreasury():GetGoldBalance()
    --     local pBuildQueue = pCity:GetBuildQueue()
    --     local currentProductionHash = pBuildQueue:GetCurrentProductionTypeHash()
    --     if (currentProductionHash == 0) then
    --         print("No current Production")
    --         Controls.GoldPurchaseButton:SetHide(true)
    --         return
    --     else
    --         local cost = 0
    --         local progress = 0
    --         local pct = 0
    --         local buildingDef	:table = GameInfo.Buildings[currentProductionHash];
	--         local districtDef	:table = GameInfo.Districts[currentProductionHash];
	--         local unitDef		:table = GameInfo.Units[currentProductionHash];
	--         local projectDef	:table = GameInfo.Projects[currentProductionHash];
	--         local type			:string= "";
    --         if(buildingDef ~= nil) then
    --             --print("Type:Buildings")
    --             --print(buildingDef.BuildingType)
    --             cost = pBuildQueue:GetBuildingCost(buildingDef.Index)
    --             progress = pBuildQueue:GetBuildingProgress(buildingDef.Index)
    --         elseif (districtDef ~= nil) then
    --             --print("Type:Districts")
    --             --print(districtDef.DistrictType)
    --             cost = pBuildQueue:GetDistrictCost(districtDef.Index)
    --             progress = pBuildQueue:GetDistrictProgress(districtDef.Index)
    --         elseif (unitDef ~= nil) then
    --             local eMilitaryFormationType = pBuildQueue:GetCurrentProductionTypeModifier();
    --             --print(eMilitaryFormationType)
    --             if (eMilitaryFormationType == MilitaryFormationTypes.STANDARD_FORMATION) then
    --                 --print("Type:Units,Standard")
    --                 cost = pBuildQueue:GetUnitCost(unitDef.Index)
    --                 progress = pBuildQueue:GetUnitProgress(unitDef.Index)
    --             elseif (eMilitaryFormationType == MilitaryFormationTypes.CORPS_FORMATION) then
    --                 --print("Type:Units,Corps")
    --                 cost = pBuildQueue:GetUnitCorpsCost(unitDef.Index)
    --                 progress = pBuildQueue:GetUnitProgress(unitDef.Index)
    --             elseif (eMilitaryFormationType == MilitaryFormationTypes.ARMY_FORMATION) then
    --                 --print("Type:Units,Army")
    --                 cost = pBuildQueue:GetUnitArmyCost(unitDef.Index)
    --                 progress = pBuildQueue:GetUnitProgress(unitDef.Index)
    --             else
    --                 --print("Type:Units,Non-Military")
    --                 cost = pBuildQueue:GetUnitCost(unitDef.Index)
    --                 progress = pBuildQueue:GetUnitProgress(unitDef.Index)
    --             end
    --             --print(unitDef.UnitType)
    --         elseif (projectDef ~= nil) then
    --             --print("Type:Projects")
    --             --print(projectDef.ProjectType)
    --             cost = pBuildQueue:GetProjectCost(projectDef.Index)
    --             progress = pBuildQueue:GetProjectProgress(projectDef.Index)
    --         end
    --         --print(cost..progress)
    --         pct = progress / cost
    --         if (pct >= 1) then
    --             print("Production Completed")
    --             Controls.GoldPurchaseButton:SetHide(true)
    --             return
    --         end
    --     end
    --     if (gold <= 1) then
    --         print("gold < 2")
    --         Controls.GoldPurchaseButton:SetHide(true)
    --         return
    --     end
    -- end
    Controls.GoldPurchaseButton:SetHide(false)
end

function PP_OnCityProductionCompleted(playerID, cityID, iConstructionType, unitID, bCancelled)
    local pCity = CityManager.GetCity(playerID, cityID)
    local pSelectedCity = UI.GetHeadSelectedCity()
    local pPlayer = Players[playerID]
    if (pPlayer ~= nil) then
        if (pPlayer:IsAI() or PlayerHasLeaderTrait(playerID, PP_Trait) == false) then
            return
        elseif (pCity ~= nil and pSelectedCity ~= nil and cityID == pSelectedCity:GetID()) then
            print("Production Complete YHG9")
            -- Controls.GoldPurchaseButton:SetHide(true)
        end
    end
end

-- function PP_OnTurnStart()
--     local pCity = UI.GetHeadSelectedCity()
--     if (pCity ~= nil) then
--         local cityID = pCity:GetID()
--         local pPlayer = pCity:GetOwner()
--         if (pPlayer ~= nil) then
--             if (pPlayer:IsAI() == false) then
--                 local playerID = pPlayer:GetID()
--                 PP_OnCityFocusChanged(playerID, cityID, 0, 0, 0, 0, 0)
--             end
--         end
--     end
-- end

function PP_OnCityProductionChanged(playerID, cityID, productionID, objectID, bCancelled)
    print("PP_OnCityProductionChanged")
    print(playerID)
    print(cityID)
    PP_OnCityFocusChanged(playerID, cityID, 0, 0, 0, 0, 0)
end

function OnGoldPurchaseButtonClicked()
    local playerID = Game.GetLocalPlayer()
    local pPlayer = Players[playerID]
    --UI.PlaySound("Play_UI_Click")
    if (pPlayer == nil) then return end
    if (PlayerHasLeaderTrait(playerID, PP_Trait)) then
        local pCity = UI.GetHeadSelectedCity()
        if (pCity ~= nil) then
            local pBuildQueue = pCity:GetBuildQueue()
            local currentProductionHash = pBuildQueue:GetCurrentProductionTypeHash()
            local projectDef	:table = GameInfo.Projects[currentProductionHash]
            PP_PopupDialogue_AddProductionProgress(playerID, pCity:GetID())
        end
    end
end

function PP_PopupDialogue_AddProductionProgress(playerID, cityID)
    local pPlayer = Players[playerID]
    if (pPlayer == nil) then return end
    local pCity = CityManager.GetCity(playerID, cityID)
    if (pCity ~= nil) then
        local multiplier = PP_GetMultiplier(playerID, cityID)
        local iProgressAdded = PP_GetProductionProgressAdd(playerID, cityID)
        if (iProgressAdded ~= 0 and iProgressAdded ~= nil) then
            local goldCost = math.ceil(iProgressAdded / percentage)
            goldPPDesc = Locale.Lookup("LOC_HUAN_PP_POPUP_1_DESCRIPTION", goldCost, math.floor(iProgressAdded * multiplier))
            local m_kPopupDialog:table = PopupDialogInGame:new( "StarAddProductionProgress" )
            m_kPopupDialog:AddTitle(goldPPTitle)
            m_kPopupDialog:AddText(goldPPDesc)
            m_kPopupDialog:AddCancelButton(goldPPCancel, function() end )
            m_kPopupDialog:AddConfirmButton(goldPPApply, function ()
                UI.PlaySound("Purchase_With_Gold");
                local kParameters = {}
                kParameters.OnStart = "PP_GoldPurchaseProduction"
                kParameters.cityID = pCity:GetID()
                kParameters.cost = goldCost
                kParameters.progress = iProgressAdded * multiplier
                UI.RequestPlayerOperation(playerID, PlayerOperations.EXECUTE_SCRIPT, kParameters)
                -- Controls.GoldPurchaseButton:SetHide(true)
            end)
            m_kPopupDialog:Open()
        end
    end
end

function PP_GetMultiplier(playerID, cityID)
    local pCity = CityManager.GetCity(playerID, cityID)
    if pCity == nil then return end

    local pBuildQueue = pCity:GetBuildQueue()
    local currentProductionHash = pBuildQueue:GetCurrentProductionTypeHash()
    if currentProductionHash == 0 then return 1 end

    local buildingDef = GameInfo.Buildings[currentProductionHash]
    local districtDef = GameInfo.Districts[currentProductionHash]
    local unitDef = GameInfo.Units[currentProductionHash]
    local projectDef = GameInfo.Projects[currentProductionHash]

    local multiplier = 1
    if Utils:GetMultiplierUsable(playerID, cityID) then
        if buildingDef ~= nil then
            multiplier = Utils:GetBuildingMultiplier(playerID, cityID, buildingDef.Index)
        elseif districtDef ~= nil then
            multiplier = Utils:GetDistrictMultiplier(playerID, cityID, districtDef.Index)
        elseif unitDef ~= nil then
            multiplier = Utils:GetUnitMultiplier(playerID, cityID, unitDef.Index)
        elseif projectDef ~= nil then
            multiplier = Utils:GetProjectMultiplier(playerID, cityID, projectDef.Index)
        end
    end

    return multiplier
end

function PP_GetProductionProgressAdd(playerID, cityID)
    local pPlayer = Players[playerID]
    if (pPlayer == nil) then return end
    local pCity = CityManager.GetCity(playerID, cityID)
    if (pCity ~= nil) then
        local gold = pPlayer:GetTreasury():GetGoldBalance()
        local pBuildQueue = pCity:GetBuildQueue()
        local currentProductionHash = pBuildQueue:GetCurrentProductionTypeHash()
        if (currentProductionHash == 0) then
            return 0
        else
            local cost = 0
            local progress = 0
            local multiplier = PP_GetMultiplier(playerID, cityID)

            local buildingDef = GameInfo.Buildings[currentProductionHash]
            local districtDef = GameInfo.Districts[currentProductionHash]
            local unitDef = GameInfo.Units[currentProductionHash]
            local projectDef = GameInfo.Projects[currentProductionHash]

            if (buildingDef ~= nil) then
                cost = pBuildQueue:GetBuildingCost(buildingDef.Index)
                progress = pBuildQueue:GetBuildingProgress(buildingDef.Index)
            elseif (districtDef ~= nil) then
                cost = pBuildQueue:GetDistrictCost(districtDef.Index)
                progress = pBuildQueue:GetDistrictProgress(districtDef.Index)
            elseif (unitDef ~= nil) then
                local eMilitaryFormationType = pBuildQueue:GetCurrentProductionTypeModifier()
                if (eMilitaryFormationType == MilitaryFormationTypes.STANDARD_FORMATION) then
                    cost = pBuildQueue:GetUnitCost(unitDef.Index)
                    progress = pBuildQueue:GetUnitProgress(unitDef.Index)
                elseif (eMilitaryFormationType == MilitaryFormationTypes.CORPS_FORMATION) then
                    cost = pBuildQueue:GetUnitCorpsCost(unitDef.Index)
                    progress = pBuildQueue:GetUnitProgress(unitDef.Index)
                elseif (eMilitaryFormationType == MilitaryFormationTypes.ARMY_FORMATION) then
                    cost = pBuildQueue:GetUnitArmyCost(unitDef.Index)
                    progress = pBuildQueue:GetUnitProgress(unitDef.Index)
                else
                    cost = pBuildQueue:GetUnitCost(unitDef.Index)
                    progress = pBuildQueue:GetUnitProgress(unitDef.Index)
                end
            elseif (projectDef ~= nil) then
                cost = pBuildQueue:GetProjectCost(projectDef.Index)
                progress = pBuildQueue:GetProjectProgress(projectDef.Index)
            end
            if (gold * percentage >= (cost - progress) / multiplier) then
                return math.ceil((cost - progress) / multiplier)
            else
                return math.floor(gold * percentage)
            end
        end
    end
end

function GBP_PP_Setup()
    local path = "/InGame/CityPanel/ActionStack"
    local ctrl = ContextPtr:LookUpControl(path)
    if ctrl ~= nil then
        Controls.GoldPurchaseButton:ChangeParent(ctrl)
    end
    Controls.GoldPurchaseButton:RegisterCallback(Mouse.eLClick,OnGoldPurchaseButtonClicked)
end

Events.LoadGameViewStateDone.Add(GBP_PP_Setup)
Events.CitySelectionChanged.Add(PP_OnCityFocusChanged)
Events.CityProductionCompleted.Add(PP_OnCityProductionCompleted)
Events.CityProductionChanged.Add(PP_OnCityProductionChanged)
-- Events.TurnBegin.Add(PP_OnTurnStart)
