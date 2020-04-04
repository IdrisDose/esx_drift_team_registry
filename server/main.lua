ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)


function getTeam(id, callback)

	MySQL.Async.fetchAll('SELECT id,name,tag,type FROM `team_registry` WHERE `id` = @identifier', {
		['@identifier'] = id
	}, function(result)
		if result[1].name ~= nil then

			local data = {
				id	= result[1].id,
				name	= result[1].name,
				tag = result[1].tag,
				color = result[1].color,

				type = result[1].type
			}
			callback(data)
		else
			local data = {
				id	= 0,
				name	= '',
				tag = '',
				color = '',
				type = ''
			}

			callback(data)
		end
	end)
end

function getTeams(callback)
	MySQL.Async.fetchAll('SELECT * FROM `team_registry`',  nil, function(result)
		callback(result)
	end)
end

function createTeam(data, callback)
	MySQL.Async.execute('INSERT INTO team_registry (name, tag, color, type) VALUES (@name, @tag, @color, @type)', {
		['@name']		= data.name,
		['@tag']		= data.tag,
		['@color']		= data.color,
		['@type']	= data.type
	},function(rowsChanged)

		if callback then
			callback(true)
		end

	end)

end

function updateTeam(data, callback)
	MySQL.Async.execute('UPDATE `team_registry` SET `name` = @name, `tag` = @tag, `color` = @color, `type` = @type WHERE id = @identifier', {
		['@identifier'] = data.id,
		['@name'] = data.name,
		['@tag'] = data.tag,
		['@color'] = data.color,
		['@type']	= data.type
	}, function(rowsChanged)
		if callback then
			callback(true)
		end
	end)

end

function deleteTeam(id, callback)
	MySQL.Async.execute('DELETE FROM `team_registry` WHERE id = @identifier', {
		['@identifier']		= id,
	}, function(rowsChanged)
		if callback then
			callback(true)
		end
	end)
end

RegisterServerEvent('esx_drift_teams:createTeam')
AddEventHandler('esx_drift_teams:createTeam', function(data, source)
	-- Get Player Perms

	createTeam(data, function(callback)
		if callback ~= true then
			TriggerClientEvent('chat:addMessage', source, { args = { '^1[TEAMS]', 'Failed to create team, try again later or contact the server admin!' } })
			local resData = {status = true, message = 'Failed to create team, try again later or contact the server admin!' }
			TriggerClientEvent('esx_drift_teams:sendErrorNotification', source, resData)
		else
			TriggerEvent('esx_drift_teams:getTeams',source)

			TriggerClientEvent('chat:addMessage', source, { args = { '^1[TEAMS]', 'Created team!' } })
			local resData = {status = true, message = 'Created team!' }
			TriggerClientEvent('esx_drift_teams:sendErrorNotification', source, resData)
		end
	end)
end)

RegisterServerEvent('esx_drift_teams:updateTeam')
AddEventHandler('esx_drift_teams:updateTeam', function(data, source)
	-- Get Player Perms

	updateTeam(data, function(callback)
		if callback ~= true then
			TriggerClientEvent('chat:addMessage', source, { args = { '^1[TEAMS]', 'Failed to create team, try again later or contact the server admin!' } })
			local resData = {status = true, message = 'Failed to create team, try again later or contact the server admin!' }
			TriggerClientEvent('esx_drift_teams:sendErrorNotification', source, resData)
		else
			TriggerEvent('esx_drift_teams:getTeams',source)

			TriggerClientEvent('chat:addMessage', source, { args = { '^1[TEAMS]', 'Updated team!' } })
			local resData = {status = true, message = 'Updated team!' }
			TriggerClientEvent('esx_drift_teams:sendErrorNotification', source, resData)
		end
	end)
end)


RegisterServerEvent('esx_drift_teams:deleteTeam')
AddEventHandler('esx_drift_teams:deleteTeam',function(teamId, source)
	-- Get Player Perms
	deleteTeam(teamId, function(result)
		if result ~= true then
			TriggerClientEvent('chat:addMessage', source, { args = { '^1[TEAMS]', 'Failed to delete team, try again later or contact the server admin!' } })
			local resData = {status = true, message = 'Failed to create team, try again later or contact the server admin!' }
			TriggerClientEvent('esx_drift_teams:sendErrorNotification', source, resData)
		else
			TriggerEvent('esx_drift_teams:getTeams',source)

			TriggerClientEvent('chat:addMessage', source, { args = { '^1[TEAMS]', 'Deleted team!' } })
			local resData = {status = true, message = 'Deleted team!' }
			TriggerClientEvent('esx_drift_teams:sendErrorNotification', source, resData)
		end
	end)

end)

RegisterServerEvent('esx_drift_teams:getTeams')
AddEventHandler('esx_drift_teams:getTeams', function(source)
	getTeams(function(data)
		local teams = {}
		for k,v in pairs(data) do
			table.insert(teams, {
				id = v.id,
				name=   v.name,
				tag = v.tag,
				color = v.color,
				type = v.type
			})
		end

		local data = {
			teamdata = teams
		}

		TriggerClientEvent('esx_drift_teams:saveTeams', source, data)
	end)
end)

AddEventHandler('onResourceStart', function(resource)
	if resource == GetCurrentResourceName() then
		Citizen.Wait(3000)

		-- Set all the client side variables for connected users one new time
		local xPlayers, xPlayer = ESX.GetPlayers()
		for i=1, #xPlayers, 1 do
			xPlayer = ESX.GetPlayerFromId(xPlayers[i])

			local myID = {
				steamid  = xPlayer.identifier,
				id = xPlayer.source
			}

			TriggerClientEvent('esx_drift_teams:setPlayerData', xPlayer.source, myID)
		end
	end
end)

TriggerEvent('es:addGroupCommand', 'teams','user', function(source, args, user)

	getTeams(function(data)
		local teams = {}

		for k,v in pairs(data) do
			table.insert(teams, {
				id = v.id,
				name=   v.name,
				tag = v.tag,
				color = v.color,
				type = v.type
			})
		end

		local data = {
			teamdata = teams
		}

		TriggerClientEvent('esx_drift_teams:showTeamManagement', source, data)
	end)
end, function(source, args, user)
	TriggerClientEvent('chat:addMessage', source, { args = { '^1SYSTEM', 'Insufficient permissions!' } })
end,{help = "Registers a new team"})
