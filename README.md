# esx_team_registry

### Features

- In-Game Chat Tags (replaces the esx_rpchat chat message thingo)
- Creating Teams for Players to join can be used as organisations
- Admin Managed

### Using Git

```
cd resources
git clone https://github.com/IdrisDose/esx_team_registry [esx]/esx_team_registry
```

### Manually

- Download https://github.com/IdrisDose/esx_team_registry
- Put it in the `[esx]` directory

## Installation

- Import `esx_identity.sql` in your database
- Add this to your `server.cfg` (ignore stop rolesFX if you dont use it):

```
start esx_team_registry
stop rolesFX
```

- If using esx_rpchat replace in `server/main.lua`:

```
AddEventHandler('chatMessage', function(playerId, playerName, message)
	if string.sub(message, 1, string.len('/')) ~= '/' then
		CancelEvent()

		playerName = GetRealPlayerName(playerId)
		TriggerClientEvent('chat:addMessage', -1, {args = {_U('ooc_prefix', playerName), message}, color = {128, 128, 128}})
	end
end)
```

with

```
-- AddEventHandler('chatMessage', function(source, name, message)
-- 	if string.sub(message, 1, string.len('/')) ~= '/' then
-- 		CancelEvent()

-- 		if Config.EnableESXIdentity then name = GetCharacterName(source) end

-- 		TriggerClientEvent('chat:addMessage', -1, { args = { _U('ooc_prefix', name), message }, color = { 128, 128, 128 } })
-- 	end
-- end)
```

### Commands

```
/teams
```

### Issues

- If using ESX RPChat removed the OOC tag. If you want OOC back in add to your esx_rpchat `server/main.lua`:

```
RegisterCommand('ooc', function(source, args, rawCommand)
	if source == 0 then
		print('esx_rpchat: you can\'t use this command from rcon!')
		return
	end

	args = table.concat(args, ' ')
	local name = GetPlayerName(source)
	if Config.EnableESXIdentity then name = GetCharacterName(source) end

	TriggerClientEvent('chat:addMessage', -1, { args = { _U('ooc_prefix', name), args }, color = { 128, 128, 128 } })
	--print(('%s: %s'):format(name, args))
end, false)
```

# Legal

### License

esx_team_registry - rp characters

Copyright (C) 2020 IdrisDose (https://github.com/IdrisDose)

This program Is free software: you can redistribute it And/Or modify it under the terms Of the GNU General Public License As published by the Free Software Foundation, either version 3 Of the License, Or (at your option) any later version.

This program Is distributed In the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty Of MERCHANTABILITY Or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License For more details.

You should have received a copy Of the GNU General Public License along with this program. If Not, see http://www.gnu.org/licenses/.

```

```
