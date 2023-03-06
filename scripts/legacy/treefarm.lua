local outOfBonemeal = false
local message = ""
local numberOfTreesChopped = 0
local waitSeconds = 5

-- status print
function status()
    term.clear()
    
    local outOfBonemealString = ""
    if outOfBonemeal then
        outOfBonemealString = "true"
    else
        outOfBonemealString = "false"
    end

    print("Tree Farm Stats:")
    print("Trees Chopped: " .. numberOfTreesChopped)
    print("Bonemeal In Slot 1: " .. turtle.getItemCount(1))
    print("Out of Bonemeal: " .. outOfBonemealString)
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

function emptyInventory()
    message = "Emptying inventory..."
    status()
    for i=2,16 do
        turtle.select(i)
        turtle.dropDown(64)
    end
    turtle.select(1)
end

function takeBonemeal()
    message = "Taking bonemeal.."
    status()
    turtle.select(1)
    turtle.suck(64 - turtle.getItemCount(1) - 1)
    if turtle.getItemCount(1) == 1 then
        outOfBonemeal = true
    else
        outOfBonemeal = false
    end
    status()
end

function replant()
    message = "Replanting..."
    status()
    spin()
    takeBonemeal()
    turtle.turnRight()
    turtle.select(2)
    turtle.suck(1)
    turtle.turnRight()
    fwd(2)
    turtle.place()
    turtle.select(1)
    status()
end

function refillBonemeal()
    message = "Refilling bonemeal..."
    status()
    bwd(2)
    spin()
    takeBonemeal()
    spin()
    fwd(2)
end

function bonemeal()
    message = "Using bonemeal..."
    status()
    turtle.select(1)

    while detectSapling() and turtle.getItemCount(1) > 1 do
        if not outOfBonemeal then
            turtle.place()
        end 

        if detectTree() then
            return
        end

        if turtle.getItemCount(1) == 1 and not outOfBonemeal then
            refillBonemeal()
        end
    end

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

function monitorTree()
    if detectSapling() and not outOfBonemeal then
        bonemeal()
    end
    if detectTree() then
        exec()
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
