local ESX = exports['es_extended']:getSharedObject()

RegisterNetEvent('wokn-bike:server:useBike', function(itemName)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end

    local bikeData = Config.Bikes[itemName]
    if not bikeData then return end

    local item = exports.ox_inventory:GetItem(src, itemName, nil, false)
    if not item or item.count < 1 then return end

    exports.ox_inventory:RemoveItem(src, itemName, 1)
    TriggerClientEvent('wokn-bike:client:spawnBike', src, itemName)
end)

RegisterNetEvent('wokn-bike:server:returnBikeItem', function(itemName)
    local src = source
    if not Config.Bikes[itemName] then return end
    exports.ox_inventory:AddItem(src, itemName, 1)
end)

RegisterNetEvent('wokn-bike:server:refundItem', function(itemName)
    local src = source
    if not Config.Bikes[itemName] then return end
    exports.ox_inventory:AddItem(src, itemName, 1)
end)
