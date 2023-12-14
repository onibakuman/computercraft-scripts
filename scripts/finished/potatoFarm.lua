-- vairables
local numPatchesFarmed = 0
local potatoAge = 0
local matureAge = 7


-- initialize position

function log(msg)
	currentStatus = msg
	status()
end

function status()
	term.clear()
	print("Potato Farm")
	print("Status: " .. currentStatus)
	print("Number of Potato Patches: " .. numPatchesFarmed)
	if potatoAge ~= nil then
		print("Potato Age: " .. potatoAge .. "/" .. matureAge)
	end
end

function detectPotato()
	local success, data = turtle.inspectDown()
	if success then
		potatoAge = data.state.age
		log("detecting potato...")
		if "minecraft:potatoes" == data.name then
			if potatoAge == matureAge then
				return true
			else
				return false
			end
		else
			return false
		end
	else
		return false
	end
end


--movement
function safeForward()
	while not turtle.forward() do sleep(1) end
end

function safeBackward()
	while not turtle.back() do sleep(1) end
end

function safeUp()
	while not turtle.up() do sleep(1) end
end

function safeDown()
	while not turtle.down() do sleep(1) end
end

function up(blocks)
	for i=1,blocks do
		safeUp()
	end
end

function dwn(blocks)
	for i=1,blocks do
		safeDown()
	end
end

function fwd(blocks)
	for i=1,blocks do
		safeForward()
	end
end

function bwd(blocks)
	for i=1,blocks do
		safeBackward()
	end
end

function left()
	turtle.turnLeft()
end

function right()
	turtle.turnRight()
end

function spin()
	left()
	left()
end

function initPosition()
	-- init position
	fwd(1)
	up(1)
	right()
	fwd(1)
	left()
	fwd(1)
end

function backToDrive()
	log("returning to drive...")
	bwd(1)
	right()
	bwd(1)
	left()
	dwn(1)
	bwd(1)
end

function harvest()
	if detectPotato() then
		turtle.digDown()
		turtle.suckDown()
	end
	log("harvested potato...")
end

function harvestColumn()
	for i=1,9 do
		harvest()
		fwd(1)
	end

	for i=1,9 do
		turtle.suckDown()
		bwd(1)
		turtle.suckDown()
	end

end

function emptyInventory()
	log("emptying inventory...")
	for i=1,16 do
		turtle.select(i)
		turtle.dropDown(turtle.getItemCount() - 1)
	end

	turtle.select(1)
end

function farmPatch()
	for i=1,9 do
		harvestColumn()
		right()
		fwd(1)
		left()
	end

	-- go to center chest to empty items
	right()
	bwd(5)
	left()
	fwd(4)
	dwn(1)

	emptyInventory()

	up(1)
	bwd(4)
	right()
	bwd(4)

	left()

	numPatchesFarmed = numPatchesFarmed + 1
end

-- main
function main()
	turtle.select(1)
	log("starting farm...")

	initPosition()

	while true do
		farmPatch()
		fwd(10)

		farmPatch()
		bwd(10)
		right()
		fwd(10)
		left()

		farmPatch()
		fwd(10)

		farmPatch()
		bwd(10)
		right()
		bwd(10)
		left()
	end


	backToDrive()
end

main()
