RegisterNetEvent('krs_subway:removeMoney', function(price)
    local source = source

    local playerMoney = exports.ox_inventory:GetItem(source, 'money', false, true)

    if playerMoney >= price then
        exports.ox_inventory:RemoveItem(source, 'money', price)
    end
end)