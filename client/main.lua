local guiEnabled = false
local teams = {}
local plyData = {}
local isDead = false


ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

AddEventHandler('esx:onPlayerDeath', function(data)
	isDead = true
end)

AddEventHandler('playerSpawned', function(spawn)
	isDead = false
end)

function EnableGui(state)
	SetNuiFocus(state, state)
	guiEnabled = state

	SendNUIMessage({
		type = "enableui",
		enable = state,
		teamdata = teams
	})
end

RegisterNetEvent('esx_drift_teams:showTeamManagement')
AddEventHandler('esx_drift_teams:showTeamManagement', function(data)
	if not isDead then
		EnableGui(true)
		teams = data.teamdata
	end
end)

RegisterNetEvent('esx_drift_teams:saveTeams')
AddEventHandler('esx_drift_teams:saveTeams', function(data)
	teams = data.teamdata
end)

RegisterNetEvent('esx_drift_teams:setPlayerData')
AddEventHandler('esx_drift_teams:setPlayerData', function(data)
	plyData = data
end)

RegisterNetEvent('esx_drift_teams:sendErrorNotification')
AddEventHandler('esx_drift_teams:sendErrorNotification', function(error)
	if error.status == true then
		ESX.ShowNotification('^1[TEAMS]^7: '..error.message)
	end
end)

RegisterNUICallback('escape', function(data, cb)
	EnableGui(false)
	cb('ok')
end)

RegisterNUICallback('teams', function(data, cb)
	-- TriggerServerEvent('esx_drift_teams:getTeams', plyData.id)
	local resData = { status = "success", data = teams }
	cb(resData)
end)

RegisterNUICallback('team/register', function(data, cb)
	local reason = ""
	local returnData = {}

	for k,v in pairs(data) do
		if v.name == 'team_name' then
			returnData.name = v.value
		elseif v.name == 'team_color' then
			returnData.color = v.value
		elseif v.name == 'team_tag' then
			returnData.tag = v.value
		elseif v.name == 'team_type' then
			returnData.type = v.value
		end
	end
	TriggerServerEvent('esx_drift_teams:createTeam', returnData, plyData.id)

	local resData = { status = "success" }
	cb(resData)
end)

RegisterNUICallback('team/edit', function(data, cb)
	local reason = ""
	local returnData = {}
	for k,v in pairs(data) do
		if v.name == 'team_name' then
			returnData.name = v.value
		elseif v.name == 'team_color' then
			returnData.color = v.value
		elseif v.name == 'team_tag' then
			returnData.tag = v.value
		elseif v.name == 'team_type' then
			returnData.type = v.value
		elseif v.name == 'team_id' then
			returnData.id = v.value
		end
	end

	TriggerServerEvent('esx_drift_teams:updateTeam', returnData, plyData.id)

	local resData = { status = "success" }
	cb(resData)
end)

RegisterNUICallback('team/delete', function(data,cb)
	TriggerServerEvent('esx_drift_teams:deleteTeam', data.teamid, plyData.id)

	local resData = { status = "success", data = teams }
	cb(resData)
end)

RegisterNUICallback('team/tag', function(data,cb)
	for k,v in pairs(teams) do
		if v.id == data.teamid then
			TriggerEvent('chat:addMessage', { args = { '^1[TEAMS]', ' TAG: ^' .. v.color .. v.tag  } })
		end
	end
	cb('ok')
end)

AddEventHandler('onResourceStop', function(resource)
	if resource == GetCurrentResourceName() then
		if guiEnabled then
			guiEnabled = false
		end
	end
end)


Citizen.CreateThread(function()
	while true do
		if guiEnabled then
			DisableControlAction(0, 1,   true) -- LookLeftRight
			DisableControlAction(0, 2,   true) -- LookUpDown
			DisableControlAction(0, 106, true) -- VehicleMouseControlOverride
			DisableControlAction(0, 142, true) -- MeleeAttackAlternate
			DisableControlAction(0, 30,  true) -- MoveLeftRight
			DisableControlAction(0, 31,  true) -- MoveUpDown
			DisableControlAction(0, 21,  true) -- disable sprint
			DisableControlAction(0, 24,  true) -- disable attack
			DisableControlAction(0, 25,  true) -- disable aim
			DisableControlAction(0, 47,  true) -- disable weapon
			DisableControlAction(0, 58,  true) -- disable weapon
			DisableControlAction(0, 263, true) -- disable melee
			DisableControlAction(0, 264, true) -- disable melee
			DisableControlAction(0, 257, true) -- disable melee
			DisableControlAction(0, 140, true) -- disable melee
			DisableControlAction(0, 141, true) -- disable melee
			DisableControlAction(0, 143, true) -- disable melee
			DisableControlAction(0, 75,  true) -- disable exit vehicle
			DisableControlAction(27, 75, true) -- disable exit vehicle
		end
		Citizen.Wait(10)
	end
end)

function verifyName(name)
	-- Don't allow short user names
	local nameLength = string.len(name)
	if nameLength > 25 or nameLength < 2 then
		return 'Your player name is either too short or too long.'
	end

	-- Don't allow special characters (doesn't always work)
	-- local count = 0
	-- for i in name:gmatch('[abcdefghijklmnopqrstuvwxyzåäöABCDEFGHIJKLMNOPQRSTUVWXYZÅÄÖ0123456789 -]') do
	-- 	count = count + 1
	-- end

	-- if count ~= nameLength then
	-- 	return 'Your player name contains special characters that are not allowed on this server.'
	-- end

	-- Does the player carry a first and last name?
	--
	-- Example:
	-- Allowed:     'Bob Joe'
	-- Not allowed: 'Bob'
	-- Not allowed: 'Bob joe'

	local spacesInName    = 0
	local spacesWithUpper = 0
	for word in string.gmatch(name, '%S+') do

		if string.match(word, '%u') then
			spacesWithUpper = spacesWithUpper + 1
		end

		spacesInName = spacesInName + 1
	end

	if spacesInName > 0 then
		return 'Your name contains more than zero spaces'
	end

	if spacesWithUpper ~= spacesInName then
		return 'your name must start with a capital letter.'
	end

	return ''
end
