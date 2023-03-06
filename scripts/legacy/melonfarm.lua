-- constants

local farmLength = 12
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
    print("Melon Farm Stats:")
    print("Cycle #: " .. cyclesIterated)
    print("Status: " .. currentMessage)
    print("Melon Slices: " .. inventoryCount)
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
    for i=1,farmLength do
	turtle.digDown()
	safeForward()
    end
end

function farmSegment()
    currentMessage = "Farming segment..."
    status()
    for i=1,2 do
        fwd(2)
        turtle.turnLeft()
        fwd(1)
        farmRow()
        turtle.turnLeft()
	fwd(2)
    end
end

function exec()
    currentMessage = "Starting cycle..."
    status()
    -- init position
    fwd(2)
    turtle.turnLeft()
    fwd(5)
    spin()
    
    -- farm 3 rows
    for i=1,2 do
        farmSegment()
        fwd(5)
    end
    farmSegment()

    -- return home
    bwd(5)
    turtle.turnLeft()
    bwd(2)

    -- empty inventory
    spin()
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
