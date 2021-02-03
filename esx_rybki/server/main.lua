ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('esx_fishing:receiveFish')
AddEventHandler('esx_fishing:receiveFish', function()
	local mathXD = math.random(1,100)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	if mathXD <= 70 then
		xPlayer.addInventoryItem('ryba', math.random(1,4))	
	else
		xPlayer.addInventoryItem('bigryba', math.random(1,2))
	end
end)

RegisterServerEvent('esx_fishing:sellAllFish')
AddEventHandler('esx_fishing:sellAllFish', function()
	local xPlayer    = ESX.GetPlayerFromId(source)

	local amountOfryba = 0
	local amountOfbigryba = 0
	local amountOfCash = 0

	for i=1, #xPlayer.inventory, 1 do
		local item = xPlayer.inventory[i]

		if item.name == "ryba" and item.count > 0 then
			amountOfryba = item.count

			amountOfCash = amountOfCash + item.count * 350
		end

		if item.name == "bigryba" and item.count > 0 then
			amountOfbigryba = item.count

			amountOfCash = amountOfCash + item.count * 500
		end
	end

	if amountOfryba > 0 then
		xPlayer.removeInventoryItem('ryba', amountOfryba)
	end
	if amountOfbigryba > 0 then
		xPlayer.removeInventoryItem('bigryba', amountOfbigryba)
	end

	if amountOfryba == 0 and amountOfbigryba == 0 then
		TriggerClientEvent('esx:showNotification', xPlayer.source, 'Negocjacje nie udane! Nie posiadasz przy sobie ryb do sprzedaży.')
	else
		cena = math.floor(amountOfCash*0.4)
		xPlayer.addMoney(cena)

		TriggerClientEvent('esx:showNotification', xPlayer.source, 'Sprzedano posiadane ryby za $' .. cena)
	end

end)

RegisterNetEvent('rybki:checkmyitem')
AddEventHandler('rybki:checkmyitem', function()
	local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
	if xPlayer.getInventoryItem('wedka').count >= 1 and xPlayer.getInventoryItem('przyneta').count >= 1 then 
		TriggerClientEvent('rybki:mam', source)
	else
		TriggerClientEvent('esx:showNotification', source, 'Nie posiadasz wędki lub/i przynęty.')
	end
end)

RegisterNetEvent('rybak:dawajwedke')
AddEventHandler('rybak:dawajwedke', function() 
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	xPlayer.addInventoryItem('wedka', '1')
end)
RegisterNetEvent('rybak:dawajprzyneta')
AddEventHandler('rybak:dawajprzyneta', function() 
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	xPlayer.addInventoryItem('przyneta', '1')
end)