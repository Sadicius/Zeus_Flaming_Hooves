function IsAdmin(steamHex)
    for _, HexCheck in ipairs(Config.AuthorizedSteamHex) do
        if steamHex == HexCheck then
            return true
        end
    end
    return false
end

RegisterServerEvent('CheckSteamHex')
AddEventHandler('CheckSteamHex', function()
    local _source = source
    local identifiers = GetPlayerIdentifiers(_source, 0)

    local steamHex = nil
    for _, id in ipairs(identifiers) do
        if string.sub(id, 1, 5) == "steam" then
            steamHex = id
            break
        end
    end

    if steamHex then
        if IsAdmin(steamHex) then
            TriggerClientEvent('SteamHexAuthorized', _source, true)
        else
            TriggerClientEvent('SteamHexAuthorized', _source, false)
        end
    else
        TriggerClientEvent('SteamHexAuthorized', _source, false)
    end
end)