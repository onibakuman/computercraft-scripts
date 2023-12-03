-- vairables
local numTreesChopped = 0
local status = ""

-- initialize position

function log(msg)
    currentStatus = msg
    status()
end

function status()
    term.clear()
    print("Tree Farm:")
    print("Status: " .. currentStatus)
    print("Number of Trees: " .. numTreesChopped)
end

function detectWood()
    local success, data = turtle.inspect()
    if success then
	    return data.name == "minecraft:jungle_log"
    else
	    return false
    end
end

function detectVine()
    local success, data = turtle.inspect()
    if success then
	    return data.name == "minecraft:vine"
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

function replenishSaplings()
    log("refilling saplings...")
    bwd(1)
    dwn(2)
    spin()
    turtle.suck(64)
    spin()
    up(2)
    fwd(1) 
end

function goToTree()
    log("proceeding to tree...")
    bwd(1) 
    up(5)
    fwd(9)
    up(1)
end

function backToDrive()
    log("returning to drive...")
    dwn(1)
    bwd(9)
    dwn(5)
    fwd(1)
end

function plantTree()
    log("planting tree...")
	turtle.select(1)

	if turtle.getItemCount(1) < 4 then
		backToDrive()
		replenishSaplings()
		goToTree()
	end

    turtle.select(1)
    up(1) 
    fwd(3)
    turtle.placeDown()
    left()
    fwd(1)
    turtle.placeDown()
    left()
    fwd(1)
    turtle.placeDown()
    left()
    fwd(1)
    turtle.placeDown()
    left()
    bwd(2)
    dwn(1)
end

function detectTree()
    fwd(1)
    if detectWood() then
        bwd(1)
        return true
    end
    
    bwd(1)
    return false
end

function waitForTree()
	while not detectTree() do
		sleep(5)
	end
	
	fwd(1)
	turtle.dig()
	bwd(1)
	numTreesChopped = numTreesChopped + 1
	cleanPlatform()
end

function cleanPlatform()
	log("cleanup time!")
	fwd(3)
	left()
	fwd(1)
	left()
	fwd(3)
	left()
	fwd(1)
	left()
end

-- main
function main()
    turtle.select(1)
    log("starting farm...")
    
    replenishSaplings()
    goToTree()
	while true do
    	plantTree()
		waitForTree()
	end

    backToDrive()
end

main()
