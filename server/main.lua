ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
Config = Config or {}


local function printTable(t,indent)

	local function printTableFunc(t,indent)
		if indent == nil then indent = "" end
		local returnTable = {}
		for key,value in pairs(t) do
			if type(value) == "table" then
				local indent2 = indent.."["..key.."]"
				table.insert(returnTable,{["value"]=value,["indent"]=indent2})
			elseif type(value) == "string" or type(value) == "number" then
				local prefix = ""
				prefix = indent
				print(prefix.."["..key.."]".." -> ","","VALUE == "..value)
			elseif type(value) == "boolean" then
				local prefix = ""
				prefix = indent
				print(prefix.."["..key.."]".." -> ","","BOOLEAN == "..tostring(value))
			else
				local value = type(value)
				local prefix = ""
				if indent ~= nil then prefix = indent end
				print(prefix.."["..key.."]".." -> ","","TYPE == "..value)
			end
		end
		return returnTable
	end

	local function callLocal(value,indent2)
		if value ~= nil then
			if type(value) == "table" then
				local currentValue,currentIndent = "",""
				returnedTable = printTableFunc(value,indent2)
				if returnedTable ~= nil then
					for key,t in pairs(returnedTable) do
						callLocal(t.value,t.indent)
					end
				end
			elseif type(value) == "string" or type(value) == "number" then
				local prefix = ""
				prefix = indent
				print(prefix.." -> ","","VALUE == "..value)
			elseif type(value) == "boolean" then
				local prefix = ""
				prefix = indent
				print(prefix.." -> ","","BOOLEAN == "..tostring(value))
			else
				local value = type(value)
				local prefix = ""
				if indent ~= nil then prefix = indent end
				print(prefix.." -> ","","TYPE == "..value)
			end
		end
	end

	callLocal(t,indent)
end


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
	MySQL.Async.fetchAll('SELECT team.id as id, team.name as name, type.type as type, team.tag as tag, team.color as color FROM `team_registry` team, `team_type` type WHERE team.type = type.id' ,  nil, function(result)
		callback(result)
	end)
end

function getTeamTypes(callback)
	MySQL.Async.fetchAll('SELECT * FROM `team_type`' ,  nil, function(result)
		callback(result)
	end)
end

function getPlayerTeams(data, callback)
	MySQL.Async.fetchAll('SELECT team.id, team.name, team.tag, team.color, type.type as type FROM team_registry team, team_players player, team_type type WHERE team.id = player.team_id AND type.id = team.type AND player.identifier = @identifier',{
		['@identifier'] = data.identifier
	}, function(result)
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

RegisterServerEvent('esx_team_registry:createTeam')
AddEventHandler('esx_team_registry:createTeam', function(data, source)
	createTeam(data, function(callback)
		if callback ~= true then
			TriggerClientEvent('chat:addMessage', source, { args = { '^1[TEAMS]', 'Failed to create team, try again later or contact the server admin!' } })
			local resData = {status = true, message = 'Failed to create team, try again later or contact the server admin!' }
			TriggerClientEvent('esx_team_registry:sendErrorNotification', source, resData)
		else
			TriggerEvent('esx_team_registry:getTeams',source)

			TriggerClientEvent('chat:addMessage', source, { args = { '^1[TEAMS]', 'Created team!' } })
			local resData = {status = true, message = 'Created team!' }
			TriggerClientEvent('esx_team_registry:sendErrorNotification', source, resData)
		end
	end)
end)

RegisterServerEvent('esx_team_registry:updateTeam')
AddEventHandler('esx_team_registry:updateTeam', function(data, source)
	-- Get Player Perms
	updateTeam(data, function(callback)
		if callback ~= true then
			TriggerClientEvent('chat:addMessage', source, { args = { '^1[TEAMS]', 'Failed to create team, try again later or contact the server admin!' } })
			local resData = {status = true, message = 'Failed to create team, try again later or contact the server admin!' }
			TriggerClientEvent('esx_team_registry:sendErrorNotification', source, resData)
		else
			TriggerEvent('esx_team_registry:getTeams',source)

			TriggerClientEvent('chat:addMessage', source, { args = { '^1[TEAMS]', 'Updated team!' } })
			local resData = {status = true, message = 'Updated team!' }
			TriggerClientEvent('esx_team_registry:sendErrorNotification', source, resData)
		end
	end)
end)


RegisterServerEvent('esx_team_registry:deleteTeam')
AddEventHandler('esx_team_registry:deleteTeam',function(teamId, source)
	-- Get Player Perms
	deleteTeam(teamId, function(result)
		if result ~= true then
			TriggerClientEvent('chat:addMessage', source, { args = { '^1[TEAMS]', 'Failed to delete team, try again later or contact the server admin!' } })
			local resData = {status = true, message = 'Failed to create team, try again later or contact the server admin!' }
			TriggerClientEvent('esx_team_registry:sendErrorNotification', source, resData)
		else
			TriggerEvent('esx_team_registry:getTeams',source)

			TriggerClientEvent('chat:addMessage', source, { args = { '^1[TEAMS]', 'Deleted team!' } })
			local resData = {status = true, message = 'Deleted team!' }
			TriggerClientEvent('esx_team_registry:sendErrorNotification', source, resData)
		end
	end)

end)

RegisterServerEvent('esx_team_registry:getTeams')
AddEventHandler('esx_team_registry:getTeams', function(source)
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

		TriggerClientEvent('esx_team_registry:saveTeams', source, data)
	end)
end)

RegisterServerEvent('esx_team_registry:getTeamTypes')
AddEventHandler('esx_team_registry:getTeamTypes', function(source)
	getTeams(function(data)
		local types = {}
		for k,v in pairs(types) do
			table.insert(teams, {
				id = v.id,
				type = v.type
			})
		end

		local data = {
			teamtypes = types
		}

		TriggerClientEvent('esx_team_registry:saveTypes', source, data)
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

			TriggerClientEvent('esx_team_registry:setPlayerData', xPlayer.source, myID)
		end
	end
end)

AddEventHandler('chatMessage', function(source, name, message)
		if string.sub(message, 1, string.len('/')) ~= '/' then
				CancelEvent()

				local player = GetPlayerIdentifiers(source)[1]
				local prefix = "";
				getPlayerTeams({identifier = player}, function(result)
					if Config.Executives[player] then
						prefix = Config.Tags["exec"]
					elseif Config.Developers[player] then
						prefix = Config.Tags["dev"]
					elseif Config.Admins[player] then
						prefix = Config.Tags["admin"]
					elseif Config.Supports[player] then
						prefix = Config.Tags["supp"]
					elseif Config.Donators[player] then
						prefix = Config.Tags["donator"]
					end

					if Config.IsPrefix then

						for k,v in pairs(result) do
							prefix = prefix .. Config.Seperator .. '^' .. v.color .. v.tag
						end

						if prefix ~= '' then
							name = prefix .. Config.Seperator .. name
						end

					else

						if prefix ~= '' then
							prefix = Config.Seperator .. prefix
						end


						for k,v in pairs(result) do
							prefix = '^' .. v.color .. v.tag .. Config.Seperator .. prefix
						end

						name = name .. prefix
					end

					TriggerClientEvent('chat:addMessage', -1, { args = {  name, message}, color = { 128, 128, 128 } })
				end)
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

		getTeamTypes(function(data)
			local types = {}

			for k,v in pairs(data) do
				table.insert(types, {
					id = v.id,
					type = v.type
				})
			end

			local data = {
				teamdata = teams,
				teamtypes =  types
			}

			TriggerClientEvent('esx_team_registry:showTeamManagement', source, data)
		end)
	end)
end, function(source, args, user)
	TriggerClientEvent('chat:addMessage', source, { args = { '^1SYSTEM', 'Insufficient permissions!' } })
end,{help = "Registers a new team"})
