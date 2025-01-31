include("qd_utils");

-- ===========================================================================
-- DealItem definition
--
-- Id: id of this deal item, also the index of resource type.
-- Type: the deal type.
-- Amount: amount of the resource.
-- MaxAmount: max amount of the resource.
-- Duration: how many turns does the deal item apply.
--
-- ===========================================================================

local m_MyOfferedItems = {}; -- List of items we offered.

-- Add the given resource to offer list. Return if this is a successful update.
function AddResourceToOffer(player, resourceIndex, maxAmount, delta)
    if delta == nil then
        delta = 1;
    end
    -- Check if the resource has already been added.
    local dealItem = m_MyOfferedItems[DealItemTypes.RESOURCES][resourceIndex];
    if dealItem then
        dealItem.Amount = math.min(dealItem.Amount + delta, maxAmount);
        m_MyOfferedItems[DealItemTypes.RESOURCES][resourceIndex] = dealItem;
        return true;
    end
    -- It's a newly added resource.
    local amount = player:GetResources():GetResourceAmount(resourceIndex);
    if amount > 0 then
        local resourceDef = GameInfo.Resources[resourceIndex];
        local duration = 0;
        if resourceDef.ResourceClassType == "RESOURCECLASS_LUXURY"
            or (not g_IsXP2Active and resourceDef.ResourceClassType == "RESOURCECLASS_STRATEGIC") then
                duration = 30;
        end
        m_MyOfferedItems[DealItemTypes.RESOURCES][resourceIndex] = {
            Id = resourceIndex,
            Type = DealItemTypes.RESOURCES,
            Amount = math.min(delta, maxAmount),
            MaxAmount = maxAmount,
            Duration = duration
        };
        return true;
    end
    return false;
end

function AddFavorToOffer(player, maxAmount, delta)
    if delta == nil then
        delta = 1;
    end
    -- Check if the item has already been added.
    local dealItem = m_MyOfferedItems[DealItemTypes.FAVOR][DIPLOMATIC_FAVOR_INDEX];
    if dealItem then
        dealItem.Amount = math.min(dealItem.Amount + delta, maxAmount);
        m_MyOfferedItems[DealItemTypes.FAVOR][DIPLOMATIC_FAVOR_INDEX] = dealItem;
        return true;
    end
    -- It's a newly added item.
    if maxAmount > 0 then
        m_MyOfferedItems[DealItemTypes.FAVOR][DIPLOMATIC_FAVOR_INDEX] = {
            Id = DIPLOMATIC_FAVOR_INDEX,
            Type = DealItemTypes.FAVOR,
            Amount = math.min(delta, maxAmount),
            MaxAmount = maxAmount,
            Duration = 0
        };
        return true;
    end
    return false;
end

function AddGreatWorkToOffer(player, id, descId)
    m_MyOfferedItems[DealItemTypes.GREATWORK][id] = {
        Id = id,
        DescId = descId,
        Type = DealItemTypes.GREATWORK,
        Amount = 1,
        MaxAmount = 1,
        Duration = 0
    };
    return true;
end

function AddAgreementToOffer(player, agreementType)
    m_MyOfferedItems[DealItemTypes.AGREEMENTS][agreementType] = {
        Id = agreementType,
        Type = DealItemTypes.AGREEMENTS,
        Amount = 1,
        MaxAmount = 1,
        Duration = 30
    };
    return true;
end

function RemoveItemsFromOffer(items:table)
    for _, item in ipairs(items) do
        if m_MyOfferedItems[item.Type][item.Id] ~= nil then
            if item.Amount ~= nil then
                local newAmount = m_MyOfferedItems[item.Type][item.Id].Amount - item.Amount;
                if newAmount > 0 then
                    m_MyOfferedItems[item.Type][item.Id].Amount = newAmount;
                else
                    m_MyOfferedItems[item.Type][item.Id] = nil;
                end
            else
                m_MyOfferedItems[item.Type][item.Id] = nil;
            end
        end
    end
end

function GetOfferedItems(dealItemType, itemId)
    if dealItemType == nil then
        return m_MyOfferedItems or {};
    elseif itemId == nil then
        return m_MyOfferedItems[dealItemType] or {};
    else
        return m_MyOfferedItems[dealItemType][itemId];
    end
end

function GetOfferedItemCount()
    local totalCount = 0;
    for dealItemType, items in pairs(m_MyOfferedItems) do
        totalCount = totalCount + table.count(items);
    end
    return totalCount;
end

function ClearOfferedItems()
    m_MyOfferedItems[DealItemTypes.RESOURCES] = {};
    m_MyOfferedItems[DealItemTypes.GREATWORK] = {};
    m_MyOfferedItems[DealItemTypes.AGREEMENTS] = {};
    if g_IsXP2Active then
        m_MyOfferedItems[DealItemTypes.FAVOR] = {};
    end
end
ClearOfferedItems();
