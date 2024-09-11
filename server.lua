local seatsTaken = {}

RegisterNetEvent('fw_sit:takePlace')
AddEventHandler('fw_sit:takePlace', function(objectCoords)
	seatsTaken[objectCoords] = true
end)

RegisterNetEvent('fw_sit:leavePlace')
AddEventHandler('fw_sit:leavePlace', function(objectCoords)
	if seatsTaken[objectCoords] then
		seatsTaken[objectCoords] = nil
	end
end)

lib.callback.register('fw_sit:getPlace', function(source, objectCoords)
	return seatsTaken[objectCoords]
end)
