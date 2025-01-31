CacheManager = {};

-- ======================================================================
-- Cache deals in the following format inside player properties:
-- {
--      "QD_SELLABLE_DEALS" = {
--          "1" = {
--              DealItemTypes.RESOURCES = { "123" = "Ivory", "456" = "Iron" },
--              DealItemTypes.GREATWORK = { "123" = "Name1", "456" = "Name2" }
--          },
--          "2" = {},
--          ...
--      }
-- }
-- ======================================================================
local SELLABLE_DEALS_KEY = "QD_SELLABLE_DEALS";
local BUYABLE_DEALS_KEY = "QD_BUYABLE_DEALS";

CacheManager.GetCachedDeals = function(isSell:boolean)
    local player = Players[Game.GetLocalPlayer()];
    if isSell then
        return player:GetProperty(SELLABLE_DEALS_KEY) or {};
    else
        return player:GetProperty(BUYABLE_DEALS_KEY) or {};
    end
end

CacheManager.SetCachedDeals = function(deals:table, isSell:boolean)
    local player = Players[Game.GetLocalPlayer()];
    if isSell then
        return player:SetProperty(SELLABLE_DEALS_KEY, deals);
    else
        return player:SetProperty(BUYABLE_DEALS_KEY, deals);
    end
end

ExposedMembers.QD = ExposedMembers.QD or {};
ExposedMembers.QD.CacheManager = CacheManager;
