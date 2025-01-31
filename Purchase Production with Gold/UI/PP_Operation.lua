function PP_GoldPurchaseProduction(playerID:number, params:table)
    local pPlayer = Players[playerID]
    local pCity = CityManager.GetCity(playerID, params.cityID)
    if (pPlayer ~= nil and pCity ~= nil) then
        pCity:GetBuildQueue():AddProgress(params.progress)
        pPlayer:GetTreasury():ChangeGoldBalance(- params.cost)
    end
end

GameEvents.PP_GoldPurchaseProduction.Add(PP_GoldPurchaseProduction)