local message = ""
local numberOfTreesChopped = 0
local waitSeconds = 5

-- status print
function status()
    term.clear()
    
    print("Tree Farm Stats:")
    print("Trees Chopped: " .. numberOfTreesChopped)
    print("Status: " .. message)
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

function chopTree()
    message = "Chopping tree..."
    status()
    turtle.select(2)
    for i=1,7 do
        turtle.dig()
        turtle.digUp()
        safeUp()
    end
    dwn(7)
    fwd(1)
    bwd(1)
    numberOfTreesChopped = numberOfTreesChopped + 1
    status()
end

function emptyAllButOne(slot)
    turtle.select(slot)
    numItems = turtle.getItemCount(slot)

    numberToDrop = numItems - 1

    if numberToDrop <= 0 then
        return
    end

    turtle.dropDown(numberToDrop)
end

function emptyInventory()
    message = "Emptying inventory..."
    status()
    for i=1,16 do
        emptyAllButOne(i)
    end
    turtle.select(1)
end

--TODO YOU ARE WORKING ON THIS FUNCTION
function replant()
    message = "Replanting..."
    status()
    turtle.select(1)
    turtle.place()
    turtle.select(1)
    status()
end

function exec()
    message = "Execting cycle..."
    status()
    chopTree()
    emptyInventory()
    bwd(2)
    replant()
end

function detectSapling()
    local success, data = turtle.inspect()
    if success then
        return data.name == "minecraft:birch_sapling"
    else
        return false
    end
end

function detectTree()
    local success, data = turtle.inspect()
    if success then
        return data.name == "minecraft:birch_log"
    else
        return false
    end
end

function main()
    message = "Starting Program..."
    status()
    replant()
    while true do
        monitorTree()
        message = "Waiting for the tree to grow..."
        status()
        sleep(waitSeconds)
    end
end

main()
