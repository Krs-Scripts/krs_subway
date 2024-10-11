local function createBlip(coords)
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(blip, 783) 
    SetBlipColour(blip, 0) 
    SetBlipScale(blip, 0.7) 
    SetBlipAsShortRange(blip, true) 
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName('Stations') 
    EndTextCommandSetBlipName(blip)
    return blip
end

local function teleportStations(spawnCoords)
    local timerDuration = cfg.subwayTimer * 1000
    -- print('Time: ', timerDuration)
    DoScreenFadeOut(800)
    while not IsScreenFadedOut() do Wait(0) end
    if lib.progressCircle({
        duration = timerDuration,
        position = 'middle',
        label = 'Traveling by train ...',
        useWhileDead = false,
        canCancel = true,
        disable = {
            car = true,
            move = true,
            combat = true,
        },
    }) then
        SetEntityCoords(cache.ped, spawnCoords)
        DoScreenFadeIn(1000)
    end
end


local function openAllStationsMenu()  
    local menuOptions = {}  
  
    for _, station in pairs(cfg.stations) do
        
        table.insert(menuOptions, {
            title = 'Trip to ' .. station.name,
            icon = 'fa-solid fa-ticket', 
            description = 'Trip to ' .. station.name .. ' for $' .. station.price,
            iconColor = '#e9ecef',
            iconAnimation = 'beatFade',
            onSelect = function(data)
                local amount = station.price

                local money = exports.ox_inventory:Search('count', 'money') 
                
                if money < amount then
                    lib.notify({title = 'Krs Subway', description = 'You don\'t have enough money!', type = 'error'})
                    return
                end
                TriggerServerEvent('krs_subway:removeMoney', amount) 
                teleportStations(station.exitMetro)  
            end,
        })
    end

    lib.registerContext({
        id = 'stations_menu',
        title = 'KRS STATIONS',  
        options = menuOptions,  
    })

    lib.showContext('stations_menu')
end

for _, station in pairs(cfg.stations) do
    lib.zones.sphere({
        coords = vec3(station.position.x, station.position.y, station.position.z), 
        size = vec3(1.6, 1.4, 3.2),
        rotation = 346.25,
        debug = false,
        onExit = function()
            lib.hideTextUI()  
        end,
        onEnter = function()
            lib.showTextUI('[E] Buy ticket') 
        end,
        inside = function()
            if IsControlJustReleased(0, 38) then  
                openAllStationsMenu()  
            end
        end,
    })
    createBlip(station.position)
end