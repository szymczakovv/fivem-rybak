
PlayerData = {}
ESX = nil
Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
	
	Citizen.Wait(5000)
	PlayerData = ESX.GetPlayerData()
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
  PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
  PlayerData.job = job
end)

local SuccessLimit = 0.09
local AnimationSpeed = 0.0015
local IsFishing = false
local CFish = false
local BarAnimation = 0
local Faketimer = 0
local RunCodeOnly1Time = true
local PosX = 0.5
local PosY = 0.1
local TimerAnimation = 0.1


CreateThread(function()
	while PlayerData.job == nil do
		Citizen.Wait(300)
	end
	while true do
		Citizen.Wait(1)
		if PlayerData.job.name == 'rybak' then
			if IsControlJustReleased(0, 167) then
				Openf6menu()
			end
			while IsFishing do
				
				local time = 4*3000
				TaskStandStill(GetPed(), time+7000)
				FishRod = AttachEntityToPed('prop_fishing_rod_01',60309, 0,0,0, 0,0,0)
				PlayAnim(GetPed(),'amb@world_human_stand_fishing@base','base',4,3000)
				Citizen.Wait(time)
				CFish = true
				IsFishing = false
			end
			while CFish do
				Citizen.Wait(1)
				FishGUI(true)
				if RunCodeOnly1Time then
					Faketimer = 1
					PlayAnim(GetPed(),'amb@world_human_stand_fishing@idle_a','idle_c',1,0)
					RunCodeOnly1Time = false
				end
				if TimerAnimation <= 0 then
					CFish = false
					TimerAnimation = 0.1
					StopAnimTask(GetPed(), 'amb@world_human_stand_fishing@idle_a','idle_c',2.0)
					Citizen.Wait(200)
					DeleteEntity(FishRod)
					TriggerEvent("esx:showNotification", "Ryba się zerwała!")
					
				end
				if IsControlJustPressed(1, 22) then
					if BarAnimation >= SuccessLimit then
						CFish = false
						TimerAnimation = 0.1
						TriggerEvent("esx:showNotification", "Złapałeś/aś rybę!")
						StopAnimTask(GetPed(), 'amb@world_human_stand_fishing@idle_a','idle_c',2.0)
						Citizen.Wait(200)
						DeleteEntity(FishRod)
						TriggerServerEvent('esx_fishing:receiveFish')
					else
						CFish = false
						TimerAnimation = 0.1
						StopAnimTask(GetPed(), 'amb@world_human_stand_fishing@idle_a','idle_c',2.0)
						Citizen.Wait(200)
						DeleteEntity(FishRod)
						TriggerEvent("esx:showNotification", "Ryba się zerwała!")
					end
				end
			end
		else
			Citizen.Wait(3000)
		end
	end
end)
CreateThread(function()
	while PlayerData.job == nil do
		Wait(500)
	end
	while true do 
		if PlayerData.job.name == 'rybak' then
			Citizen.Wait(1000)
			Faketimer = Faketimer + 1 
		else
			Citizen.Wait(3000)
		end
	end 
end)

function GetPed() 
	return 
	GetPlayerPed(-1) 
end
function text(x,y,scale,text)
    SetTextFont(0)
    SetTextProportional(0)
    SetTextScale(scale, scale)
    SetTextColour(255,255,255,255)
    SetTextDropShadow(0,0,0,0,255)
    SetTextEdge(2, 0, 0, 0, 255)
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x, y)
end
function FishGUI(bool)
	if not bool then return end
	DrawRect(PosX,PosY+0.005,TimerAnimation,0.005,255,255,0,255)
	DrawRect(PosX,PosY,0.1,0.01,0,0,0,255)
	TimerAnimation = TimerAnimation - 0.0001025
	if BarAnimation >= SuccessLimit then
		DrawRect(PosX,PosY,BarAnimation,0.01,102,255,102,150)
	else
		DrawRect(PosX,PosY,BarAnimation,0.01,255,51,51,150)
	end
	if BarAnimation <= 0 then
		up = true
	end
	if BarAnimation >= PosY then
		up = false
	end
	if not up then
		BarAnimation = BarAnimation - AnimationSpeed
	else
		BarAnimation = BarAnimation + AnimationSpeed
	end
	text(0.41,0.05,0.35, "UŻYJ [~g~SPACJI~s~] ABY ZACIĄĆ RYBĘ!")
end
function PlayAnim(ped,base,sub,nr,time) 
	CreateThread(function() 
		RequestAnimDict(base) 
		while not HasAnimDictLoaded(base) do 
			Citizen.Wait(1) 
		end
		if IsEntityPlayingAnim(ped, base, sub, 3) then
			ClearPedSecondaryTask(ped) 
		else 
			for i = 1,nr do 
				TaskPlayAnim(ped, base, sub, 8.0, -8, -1, 16, 0, 0, 0, 0) 
				Citizen.Wait(time) 
			end 
		end 
	end) 
end
function AttachEntityToPed(prop,bone_ID,x,y,z,RotX,RotY,RotZ)
	BoneID = GetPedBoneIndex(GetPed(), bone_ID)
	obj = CreateObject(GetHashKey(prop),  1729.73,  6403.90,  34.56,  true,  true,  true)
	vX,vY,vZ = table.unpack(GetEntityCoords(GetPed()))
	xRot, yRot, zRot = table.unpack(GetEntityRotation(GetPed(),2))
	AttachEntityToEntity(obj,  GetPed(),  BoneID, x,y,z, RotX,RotY,RotZ,  false, false, false, false, 2, true)
	return obj
end

local HasAlreadyEnteredMarker = false
local LastZone = nil
local CurrentAction = nil
local FishHooked = FISH_WAITING
local CurrentFishingOdds = 0
local CurrentPikeLeaderboad = {}
local CurrentBassLeaderboad = {}
local CurrentSalmonLeaderboad = {}
local CurrentLeaderboard = nil

local FISH_WAITING = 1
local FISH_HOOKED = 2
local FISH_CAUGHT = 3

local ACTION_FISHING = 'fishing'
local ACTION_IN_FISHING_ZONE = 'in_fishing_zone'
local ACTION_SELLING_FISH = 'selling_fish'
local ACTION_FISHING_LEADERBOARD = 'fishing_leaderboard'

local CaughtTest = nil
local CaughtFish = nil

function DrawScreenText(text, color, position, size, center)
	SetTextCentre(center)
	SetTextColour(color[1], color[2], color[3], color[4])
	SetTextFont(color[5])
	SetTextScale(size[1], size[2])
	Citizen.InvokeNative(0x61BB1D9B3A95D802, 7)
	SetTextEntry("STRING")
	AddTextComponentString(text)
	DrawText(position[1], position[2])
end

function DrawScreenRect(color, position, size)
	Citizen.InvokeNative(0x61BB1D9B3A95D802, 6)
	DrawRect(position[1], position[2], size[1], size[2], color[1], color[2], color[3], color[4])
end

RegisterNetEvent('esx_fishing:playFishingAnimation')
AddEventHandler('esx_fishing:playFishingAnimation', function()
	TaskStartScenarioInPlace(GetPlayerPed(-1), "WORLD_HUMAN_STAND_FISHING", 0, false)
	FishHooked = FISH_WAITING
  Citizen.Wait(1000)
  CurrentAction = ACTION_FISHING
end)
local wedka = false
CreateThread(function()
	while PlayerData.job == nil do
		Wait(500)
	end
	while true do
		Citizen.Wait(300)
		if PlayerData.job.name == 'rybak' then

			if wedka == true then
				local playerPedPos = GetEntityCoords(GetPlayerPed(-1), true)
				local fishingRod = GetClosestObjectOfType(playerPedPos, 10.0, GetHashKey("prop_fishing_rod_01"), false, false, false)
				SetEntityAsMissionEntity(fishingRod, 1, 1)
				DeleteEntity(fishingRod)
				wedka = false
			else
				Wait(500)
			end
		else
			Citizen.Wait(2000)
		end
	end
end)


CreateThread(function()
	while PlayerData.job == nil do
		Citizen.Wait(300)
	end
	while true do
		Citizen.Wait(1)
		if PlayerData.job.name == 'rybak' then
				local coords = GetEntityCoords(GetPlayerPed(-1))
				for i=1, #Config.MainMenu, 1 do
					if(GetDistanceBetweenCoords(coords, Config.MainMenu[i].x, Config.MainMenu[i].y, Config.MainMenu[i].z, true) < 10)  then
						sleep = false
						DrawMarker(22, Config.MainMenu[i].x, Config.MainMenu[i].y, Config.MainMenu[i].z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, Config.MarkerSize.x, Config.MarkerSize.y, Config.MarkerSize.z, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 500, false, true, 10, false, false, false, false)
					end
				end
				for i=1, #Config.Sell, 1 do
					if(GetDistanceBetweenCoords(coords, Config.Sell[i].x, Config.Sell[i].y, Config.Sell[i].z, true) < 10) then
						sleep = false
						DrawMarker(22, Config.Sell[i].x, Config.Sell[i].y, Config.Sell[i].z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, Config.MarkerSize.x, Config.MarkerSize.y, Config.MarkerSize.z, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 500, false, true, 10, false, false, false, false)
					end
				end
				for i=1, #Config.StoreVehicle, 1 do
					if(GetDistanceBetweenCoords(coords, Config.StoreVehicle[i].x, Config.StoreVehicle[i].y, Config.StoreVehicle[i].z, true) < 60) then
						sleep = false
						if IsPedInAnyVehicle(GetPlayerPed(-1)) then
							DrawMarker(1, Config.StoreVehicle[i].x, Config.StoreVehicle[i].y, Config.StoreVehicle[i].z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 15.5, 15.5, 3.5, 247, 187, 60, 500, false, true, 2, false, false, false, false)
						end
					end
				end
				for i=1, #Config.GetVehicle, 1 do
					if(GetDistanceBetweenCoords(coords, Config.GetVehicle[i].x, Config.GetVehicle[i].y, Config.GetVehicle[i].z, true) < 10) then
						sleep = false
						DrawMarker(22, Config.GetVehicle[i].x, Config.GetVehicle[i].y, Config.GetVehicle[i].z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 1.5, 1.5, 1.5, 247, 187, 60, 500, false, true, 2, false, false, false, false)
					end
				end
			if sleep then
				Citizen.Wait(3000)
			end
		end
	end
end)

CreateThread(function()
	while PlayerData.job == nil do
		Citizen.Wait(300)
	end
	while true do
		Citizen.Wait(1)
		if PlayerData.job.name == 'rybak' then
		local coords      = GetEntityCoords(GetPlayerPed(-1))
		isInRybakMainmenu  = false
		local currentZone = nil
		for i=1, #Config.MainMenu, 1 do
				if(GetDistanceBetweenCoords(coords, Config.MainMenu[i].x, Config.MainMenu[i].y, Config.MainMenu[i].z, true) < Config.MarkerSize.x) then
						isInRybakMainmenu = true
						SetTextComponentFormat('STRING')
						AddTextComponentString("Naciśnij ~INPUT_CONTEXT~ aby otworzyć menu rybaka.")
						DisplayHelpTextFromStringLabel(0, 0, 1, -1)
					if IsControlJustReleased(0, 38) and isInRybakMainmenu and not menuIsShowed then
						--giga funckja
						Openmainmenu()
					end

				end
		end
		for i=1, #Config.GetVehicle, 1 do
			if(GetDistanceBetweenCoords(coords, Config.GetVehicle[i].x, Config.GetVehicle[i].y, Config.GetVehicle[i].z, true) < Config.MarkerSize.x) then
					isInRybakGetVehicle = true
					SetTextComponentFormat('STRING')
					AddTextComponentString("Naciśnij ~INPUT_CONTEXT~ aby otworzyć garaż.")
					DisplayHelpTextFromStringLabel(0, 0, 1, -1)
				if IsControlJustReleased(0, 38) and isInRybakGetVehicle and not menuIsShowed then
					--giga funckja
					OpenuGarage()
				end

			end
		end
		for i=1, #Config.Sell, 1 do
			if(GetDistanceBetweenCoords(coords, Config.Sell[i].x, Config.Sell[i].y, Config.Sell[i].z, true) < Config.MarkerSize.x) then
					isInRybakSell = true
					SetTextComponentFormat('STRING')
					AddTextComponentString("Naciśnij ~INPUT_CONTEXT~ aby sprzedać ryby.")
					DisplayHelpTextFromStringLabel(0, 0, 1, -1)
				if IsControlJustReleased(0, 38) and isInRybakSell and not menuIsShowed then
					FreezeEntityPosition(PlayerPedId(), true)
					TaskStartScenarioInPlace(GetPlayerPed(-1), "WORLD_HUMAN_CLIPBOARD", 0, false)
					TriggerEvent('esx:showNotifiaction', 'Negocjujesz z rybakiem o cenę ryby.')
					Citizen.Wait(20000)
					TriggerServerEvent('esx_fishing:sellAllFish')
					FreezeEntityPosition(PlayerPedId(), false)
					ClearPedTasksImmediately(PlayerPedId())
				end

			end
		end
		for i=1, #Config.StoreVehicle, 1 do
			if(GetDistanceBetweenCoords(coords, Config.StoreVehicle[i].x, Config.StoreVehicle[i].y, Config.StoreVehicle[i].z, true) < 10.0) then
					isInRybakStorevehicle = true
					SetTextComponentFormat('STRING')
					AddTextComponentString("Naciśnij ~INPUT_CONTEXT~ schować łódkę do garażu.")
					DisplayHelpTextFromStringLabel(0, 0, 1, -1)
				if IsControlJustReleased(0, 38) and isInRybakStorevehicle and not menuIsShowed then
					--giga funckja
					local veh,dist = ESX.Game.GetClosestVehicle(playerCoords)
					if dist < 3 then
						DeleteEntity(veh)
						ESX.ShowNotification("~b~Łódka Zaparkowana")
						Citizen.Wait(300)
						local ped = PlayerPedId()
						SetPedCoordsKeepVehicle(ped, 1683.12, 41.32, 161.77);
					else
						ESX.ShowNotification("~r~Nie znajdujesz się w łódce")
					end
					insideMarker = false
				end

			end
		end
		if isInRybakMainmenu and not hasAlreadyEnteredMarker then
			hasAlreadyEnteredMarker = true
			sleep = false
		end
		if isInRybakGetVehicle and not hasAlreadyEnteredMarker then
			hasAlreadyEnteredMarker = true
			sleep = false
		end
		if isInRybakStorevehicle and not hasAlreadyEnteredMarker then
			hasAlreadyEnteredMarker = true
			sleep = false
		end
		if isInRybakSell and not hasAlreadyEnteredMarker then
			hasAlreadyEnteredMarker = true
			sleep = false
		end
		if sleep then
			Citizen.Wait(3000)
		end
	else
		Citizen.Wait(200)
	end
	end
end)

function Openf6menu()
    ESX.UI.Menu.CloseAll()
    ESX.UI.Menu.Open(
        'default', GetCurrentResourceName(), 'szafka',
        {
			align    = 'center',
            title    = 'Rybak',
            elements = {
			  {label = 'Zarzuć Wędkę', value = 'pal'},
            }
        },
        function(data, menu)
			if data.current.value == 'pal' then
				TriggerServerEvent('rybki:checkmyitem')
            end
        end,
        function(data, menu)
			menu.close()
        end
	)
end

RegisterNetEvent('rybki:mam')
AddEventHandler('rybki:mam', function()
	-- bolek i lolek byl by dumny
	if not IsPedInAnyVehicle(GetPed(), false) then
		if not IsPedSwimming(GetPed()) then
			IsFishing = true
			TriggerEvent("esx:showNotification", "Zarzucono zanętę, czekaj na rybę...")
			RunCodeOnly1Time = true
			BarAnimation = 0
			CurrentAction = ACTION_FISHING
		end
	end
end)

local Clothes = {
	Male = {
		['tshirt_1'] = 15, ['tshirt_2'] = 0,
		['torso_1'] = 126, ['torso_2'] = 0,
		['decals_1'] = 0, ['decals_2'] = 0,
		['arms'] = 0,
		['pants_1'] = 47, ['pants_2'] = 1,
		['shoes_1'] = 54, ['shoes_2'] = 0,
		['helmet_1'] = 6, ['helmet_2'] = 3,
		['chain_1'] = 0, ['chain_2'] = 0,
		['ears_1'] = -1, ['ears_2'] = 0,
		['bproof_1'] = 0, ['bproof_2'] = 0,
		['mask_1'] = 0, ['mask_2'] = 0,
		['bags_1'] = 0, ['bags_2'] = 0
	},
	Female = {
		['tshirt_1'] = 15, ['tshirt_2'] = 0,
		['torso_1'] = 126, ['torso_2'] = 0,
		['decals_1'] = 0, ['decals_2'] = 0,
		['arms'] = 0,
		['pants_1'] = 47, ['pants_2'] = 1,
		['shoes_1'] = 54, ['shoes_2'] = 0,
		['helmet_1'] = 6, ['helmet_2'] = 3,
		['chain_1'] = 0, ['chain_2'] = 0,
		['ears_1'] = -1, ['ears_2'] = 0,
		['bproof_1'] = 0, ['bproof_2'] = 0,
		['mask_1'] = 0, ['mask_2'] = 0,
		['bags_1'] = 0, ['bags_2'] = 0
	},
}

function reloadskin()
    SetPlayerHealthRechargeMultiplier(PlayerId(), 0.0)
    ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
        TriggerEvent('skinchanger:loadSkin', skin)
    end)
    TriggerEvent('esx_tattooshop:refreshTattoos')
end

function GetPedData()
	return Ped
end

function Openmainmenu()
    ESX.UI.Menu.CloseAll()
    ESX.UI.Menu.Open(
        'default', GetCurrentResourceName(), 'szafka',
        {
			align    = 'center',
            title    = 'Rybak',
            elements = {
				--[[{label = 'Ubranie Robocze', value = 'ppal'},
				{label = 'Ubranie Cywilne', value = 'ggume'},]]
				{label = 'Garderoba', value = 'garderoba'},
				{label = 'Weź Wędkę', value = 'pedaly'},
				{label = 'Weź Przynętę', value = 'xddddddddd'},
            }
        },
		function(data, menu)
			if data.current.value == 'garderoba' then
				--table.insert(elements, {label = 'Ubranie Robocze', value = 'ppal'})
				--table.insert(elements, {label = 'Ubranie Cywilne', value = 'ggume'})
				Openubrania()
			elseif data.current.value == 'xddddddddd' then
				TriggerServerEvent('rybak:dawajprzyneta')
			elseif data.current.value == 'pedaly' then
				TriggerServerEvent('rybak:dawajwedke')
			elseif data.current.value == 'ppal' then
				ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
					if skin.sex == 0 then
						TriggerEvent('skinchanger:loadClothes', skin, Clothes.Male)
					else
						TriggerEvent('skinchanger:loadClothes', skin, Clothes.Female)
					end
				end)
			elseif data.current.value == 'ggume' then
				ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
					TriggerEvent('skinchanger:loadSkin', skin)
						GetPedData()
						reloadskin()
						TriggerEvent('esx_tattooshop:refreshTattoos')
				  end)
			end
        end,
        function(data, menu)
			menu.close()
        end
	)
end

function Openubrania()
    ESX.UI.Menu.CloseAll()
    ESX.UI.Menu.Open(
        'default', GetCurrentResourceName(), 'szafka',
        {
			align    = 'center',
            title    = 'Rybak',
            elements = {
				{label = 'Ubranie Robocze', value = 'ppal'},
				{label = 'Ubranie Cywilne', value = 'ggume'},
            }
        },
		function(data, menu)
			if data.current.value == 'ppal' then
				ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
					if skin.sex == 0 then
						TriggerEvent('skinchanger:loadClothes', skin, Clothes.Male)
					else
						TriggerEvent('skinchanger:loadClothes', skin, Clothes.Female)
					end
				end)
			elseif data.current.value == 'ggume' then
				ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
					TriggerEvent('skinchanger:loadSkin', skin)
						GetPedData()
						reloadskin()
						TriggerEvent('esx_tattooshop:refreshTattoos')
				  end)
			end
        end,
        function(data, menu)
			Openmainmenu()
        end
	)
end


function OpenuGarage()
    ESX.UI.Menu.CloseAll()
    ESX.UI.Menu.Open(
        'default', GetCurrentResourceName(), 'szafka',
        {
			align    = 'center',
            title    = 'Rybak',
            elements = {
				{label = 'Wyciągnij Łódkę', value = 'lubiewdupe'},
            }
        },
		function(data, menu)
			if data.current.value == 'lubiewdupe' then
				menu.close()
				RequestModel("Dinghy2")
				Citizen.Wait(100)
				local Dinghy2 = CreateVehicle("Dinghy2", 1680.09, 32.13, 161.61, 275.0, true, true)
				SetPedIntoVehicle(GetPlayerPed(-1), Dinghy2, -1)
			end
        end,
        function(data, menu)
			menu.close()
        end
	)
end

