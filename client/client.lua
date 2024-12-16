local activeFlamingHooves = {}
local Horse
local Authorize = false
local alreadyChecked = false
local canActivate = false

RegisterNetEvent('SteamHexAuthorized')
AddEventHandler('SteamHexAuthorized', function(isAuthorized)
    if alreadyChecked then
        return
    end

    if isAuthorized then
        Authorize = true
        if Config.Debug then
            print("You are authorized!")
        end
    else
        Authorize = false
        if Config.Debug then
            print("You are not authorized.")
        end
    end

    alreadyChecked = true
end)

TriggerServerEvent('CheckSteamHex')

local function CountFlamingHooves()
    local count = 0
    for _, hasFlamingHooves in pairs(activeFlamingHooves) do
        if hasFlamingHooves then
            count = count + 1
        end
    end
    return count
end

local function FlamingHooves()
    local playerPed = PlayerPedId()
    Horse = GetMount(playerPed)

    if not Horse or Horse == 0 then
        print("You are not riding a horse")
        return
    end

    local HorseModel = GetEntityModel(Horse)
    local isValidHorse = false

    for _, horseName in ipairs(Config.Horses) do
        if HorseModel == GetHashKey(horseName) then
            isValidHorse = true
            break
        end
    end

    if isValidHorse then
        if activeFlamingHooves[Horse] then
            SetPedConfigFlag(Horse, 207, false)
            activeFlamingHooves[Horse] = nil
            print("Flaming hooves removed from the horse")
        else
            canActivate = true
            if Config.LimitEnable then
                local currentFlamingHoovesCount = CountFlamingHooves()
                if currentFlamingHoovesCount >= Config.Limit then
                    canActivate = false
                    print("Flaming hooves limit reached. Cannot activate for this horse")
                end
            end

            if canActivate then
                SetPedConfigFlag(Horse, 207, true)
                activeFlamingHooves[Horse] = true
                print("Flaming hooves activated!")
            end
        end
    else
        print("This horse cannot have flaming hooves")
    end
end

CreateThread(function()
    while true do
        Wait(2000) -- 1000

        for horse, _ in pairs(activeFlamingHooves) do
            if not DoesEntityExist(horse) or IsEntityDead(horse) then
                activeFlamingHooves[horse] = nil
                if Config.Debug then
                    print("A horse has died or been deleted/removed, removing from active flaming hooves list!")
                end
            end
        end
    end
end)

RegisterCommand(Config.Command, function()
    if Authorize then
        FlamingHooves()
    else
        print("You are not authorized to use this command")
    end
end, false)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
    SetPedConfigFlag(Horse, 207, false)
        if Config.Debug then
            print("All flaming hooves cleared from the horses")
        end
    end
end)
