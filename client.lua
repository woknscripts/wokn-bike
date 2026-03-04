local spawnedBike = nil
local currentItem = nil

local function deleteBike()
    if spawnedBike and DoesEntityExist(spawnedBike) then
        DeleteEntity(spawnedBike)
    end
    spawnedBike = nil
    currentItem = nil
end

local function spawnBike(model)
    local modelHash = GetHashKey(model)
    RequestModel(modelHash)
    local timeout = 0
    while not HasModelLoaded(modelHash) do
        Wait(10)
        timeout = timeout + 10
        if timeout > 5000 then return nil end
    end

    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)
    local rad = math.rad(heading)

    local sx = coords.x + Config.SpawnOffset.x * math.sin(-rad) + Config.SpawnOffset.y * math.cos(-rad)
    local sy = coords.y + Config.SpawnOffset.x * math.cos(rad) + Config.SpawnOffset.y * math.sin(rad)
    local sz = coords.z + Config.SpawnOffset.z

    local vehicle = CreateVehicle(modelHash, sx, sy, sz, heading, true, false)
    SetModelAsNoLongerNeeded(modelHash)

    local t = 0
    while not DoesEntityExist(vehicle) do
        Wait(10)
        t = t + 10
        if t > 3000 then return nil end
    end

    SetVehicleOnGroundProperly(vehicle)
    SetEntityAsMissionEntity(vehicle, true, true)
    return vehicle
end

RegisterNetEvent('wokn-bike:client:spawnBike', function(itemName)
    if spawnedBike and DoesEntityExist(spawnedBike) then
        lib.notify({ title = 'Bike', description = 'You already have a bike spawned.', type = 'error' })
        TriggerServerEvent('wokn-bike:server:refundItem', itemName)
        return
    end

    local bikeData = Config.Bikes[itemName]
    if not bikeData then return end

    local vehicle = spawnBike(bikeData.model)
    if not vehicle then
        lib.notify({ title = 'Bike', description = 'Failed to spawn bike.', type = 'error' })
        TriggerServerEvent('wokn-bike:server:refundItem', itemName)
        return
    end

    spawnedBike = vehicle
    currentItem = itemName
    lib.notify({ title = bikeData.label, description = 'Bike spawned! Use /returnbike to store it.', type = 'success' })
end)

local function doReturn()
    if not spawnedBike or not DoesEntityExist(spawnedBike) then
        lib.notify({ title = 'Bike', description = 'No bike to return.', type = 'error' })
        return
    end

    local ped = PlayerPedId()
    if GetVehiclePedIsIn(ped, false) == spawnedBike then
        TaskLeaveVehicle(ped, spawnedBike, 0)
        Wait(1500)
    end

    local item = currentItem
    deleteBike()
    TriggerServerEvent('wokn-bike:server:returnBikeItem', item)
    lib.notify({ title = 'Bike', description = 'Bike stored back in inventory.', type = 'success' })
end

RegisterCommand('returnbike', doReturn, false)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        deleteBike()
    end
end)

exports('useBike', function(data)
    TriggerServerEvent('wokn-bike:server:useBike', data.name)
end)
