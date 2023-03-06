-- constants

local farmLength = 9
local sleepTimeMin = 5
local sleepDuration = sleepTimeMin * 60

-- counters
local cyclesIterated = 1
local currentMessage = ""
local inventoryCount = 0

function countInventory()
    local total = 0
    for i=1,16 do
        total = total + turtle.getItemCount(i)
    end

    inventoryCount = total
end

function status()
    countInventory()
    term.clear()
    print("Hemp Farm Stats:")
    print("Cycle #: " .. cyclesIterated)
    print("Status: " .. currentMessage)
end

-- movement
function safeForward()
    while not turtle.forward() do end
end

function safeBackward()
    while not turtle.back() do end
end

function safeUp()
    while not turtle.up() do end
end

function safeDown()
    while not turtle.down() do end
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

function spin()
    turtle.turnRight()
    turtle.turnRight()
end

function emptyInventory()
    currentMessage = "Emptying inventory..."
    status()
    for i=1,16 do
        turtle.select(i)
        turtle.drop(64)
    end
    turtle.select(1)
end

function farmRow()
    currentMessage = "Clearing row..."
    status()
    for i=1,farmLength - 1 do
	turtle.digDown()
	safeForward()
    end
    turtle.digDown()
end

-- default goes right set to true for left
function farmSegment(isMirrored)
    local turn, unturn = nil
    local direction = ""

    local function l() turtle.turnLeft() end
    local function r() turtle.turnRight() end

    if isMirrored then
	direction = "left"
	turn = {e = l}
	unturn = {e = r}
    else
	direction = "right"
	turn = {e = r}
	unturn = {e = l}
    end

    currentMessage = "Farming segment to the " .. direction
    status()
    for i=1,8 do
	farmRow()
	bwd(farmLength - 1)
	turn.e()
	fwd(1)
	unturn.e()
    end
    farmRow()
    bwd(farmLength - 1)
    unturn.e()
    fwd(farmLength - 1)
    turn.e()
end

function exec()
    currentMessage = "Starting cycle..."
    status()
    -- init position
    up(1)
    fwd(1)
    turtle.turnRight()
    fwd(1)
    turtle.turnLeft()

    -- farm right side
    farmSegment()

    -- go to left side
    turtle.turnRight()
    bwd(2)
    turtle.turnLeft()
    
    -- farm left side
    farmSegment(true)

    -- empty inventory
    bwd(1)
    turtle.turnRight()
    fwd(1)
    turtle.turnRight()
    dwn(1)
    emptyInventory()
    spin()
    currentMessage = "Ending cycle..."
    status()

    -- increment counter
    cyclesIterated = cyclesIterated + 1
end

function main()
    while true do
	exec()
    	currentMessage = "Sleeping for " .. sleepTimeMin .. " minutes..."
    	status()
	sleep(sleepDuration)
    end
end

main()
