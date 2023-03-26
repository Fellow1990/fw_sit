local sitting, currentSitCoords, currentScenario = {}
local disableControls = false
local currentObj = nil

RegisterCommand('wakeup', function()
	wakeup()
end, false)

RegisterKeyMapping('wakeup', 'Wake up', 'keyboard', Config.Keyboard)

CreateThread(function()
	local Sitables = {}
	for k,v in pairs(Config.Interactables) do
		local model = GetHashKey(v)
		table.insert(Sitables, model)
	end
	Wait(100)
	exports.ox_target:addModel(Sitables, {
		{
			icon = Config.Visual.icon,
			label = Config.Visual.label,
			event = "esx_sit:sit",
			Distance = Config.MaxDistance
		},
	})
end)

RegisterNetEvent("esx_sit:sit")
AddEventHandler("esx_sit:sit", function()
	if sitting and not IsPedUsingScenario(PlayerPedId(), currentScenario) then
		wakeup()
	end
	if disableControls then
		DisableControlAction(1, 37, true)
	end
	local object, distance = GetNearChair()
	if distance and distance < Config.MaxDistance then
		local hash = GetEntityModel(object)
		for k,v in pairs(Config.Sitable) do
			if GetHashKey(k) == hash then
				sit(object, k, v)
				break
			end
		end
	end
end)

function GetNearChair()
	local object, distance
	local coords = GetEntityCoords(PlayerPedId())
	for i=1, #Config.Interactables do
		object = GetClosestObjectOfType(coords, 3.0, GetHashKey(Config.Interactables[i]), false, false, false)
		distance = #(coords - GetEntityCoords(object))
		if distance < Config.MaxDistance then
			return object, distance
		end
	end
	return nil, nil
end

function wakeup()
	TaskStartScenarioAtPosition(PlayerPedId(), currentScenario, 0.0, 0.0, 0.0, 180.0, 2, true, false)
	while IsPedUsingScenario(PlayerPedId(), currentScenario) do
		Wait(100)
	end
	ClearPedTasks(PlayerPedId())
	FreezeEntityPosition(PlayerPedId(), false)
	FreezeEntityPosition(currentObj, false)
	TriggerServerEvent('esx_sit:leavePlace', currentSitCoords)
	currentSitCoords, currentScenario = nil, nil
	sitting = false
	disableControls = false
end

function sit(object, modelName, data)
	if not HasEntityClearLosToEntity(PlayerPedId(), object, 17) then
		return
	end
	disableControls = true
	currentObj = object
	FreezeEntityPosition(object, true)
	PlaceObjectOnGroundProperly(object)
	local pos = GetEntityCoords(object)
	local playerPos = GetEntityCoords(PlayerPedId())
	local objectCoords = pos.x .. pos.y .. pos.z
	ESX.TriggerServerCallback('esx_sit:getPlace', function(occupied)
		if occupied then
			lib.notify({
				title = Config.Visual.notification,
				type = 'info'
			})
		else
			lastPos, currentSitCoords = GetEntityCoords(PlayerPedId()), objectCoords
			TriggerServerEvent('esx_sit:takePlace', objectCoords)
			currentScenario = data.scenario
			TaskStartScenarioAtPosition(PlayerPedId(), currentScenario, pos.x, pos.y, pos.z + (playerPos.z - pos.z)/2, GetEntityHeading(object) + 180.0, 0, true, false)
			Citizen.Wait(2500)
			if GetEntitySpeed(PlayerPedId()) > 0 then
				ClearPedTasks(PlayerPedId())
				TaskStartScenarioAtPosition(PlayerPedId(), currentScenario, pos.x, pos.y, pos.z + (playerPos.z - pos.z)/2, GetEntityHeading(object) + 180.0, 0, true, true)
			end
			sitting = true
		end
	end, objectCoords)
end