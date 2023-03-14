-- constants
local buildingDistanceFromStart = 20
local lavaBucketSlot = 15
local waterBucketSlot = 16
local buildingSeperation = 5

-- set once
local currentStatus = "..."
local numberOfLayers = 0
local radius = 0
local roofHeight = 0
local lavaSpreadTime = 0

-- updated each row
local currentColumn = 1
local currentColumnRadius = 0
local currentPositionInColumn = 1

-- updated on finished quadrant only
local currentQuadrant = 1

-- coordinates and drection
local direction = 0
local x = 0
local y = 0
local z = 0

-- saved last spot when empty
local savedDirection = 0
local savedX = 0
local savedY = 0
local savedZ = 0

function log(msg)
    currentStatus = msg
    status()
end

function getUserInput()
    log("getting user input...")
    print("please enter the number of layers you want for the roof: ")
    local userInput = read()
    numberOfLayers = userInput
    radius = numberOfLayers * 3

    term.clear()

    print("please enter the height of the roof: ")
    userInput = read()
    roofHeight = userInput
    lavaSpreadTime = (radius * 2) + (roofHeight * 2) + (4 * 2) -- last one is floor spread

    term.clear()
end

function status()
    term.clear()
    print("Structure Builder:")
    print("Status: " .. currentStatus)
    print("Number of Layers: " .. numberOfLayers)
    print("Radius: " .. radius)
    print("Current Column: " .. currentColumn)
    print("X: " .. x .. " Y: " .. y .. " Z: " .. z)
end

function detectCobble()
    local success, data = turtle.inspectDown()
    if success then
	    return data.name == "minecraft:cobblestone"
    else
	    return false
    end
end

function put()
    log("placing block...")
    local success = turtle.placeDown()
    local firstFilledSpot = nil
    while not success and firstSlot == nil do
      firstFilledSlot = getFirstUsedSlot()
      if firstFilledSlot == nil then
	log("inventory empty, saving coordinates and refilling...")
        saveCoordinates()
        local clearanceHeight = returnToOrigin()
        refillInventory()
        returnToSaved(clearanceHeight)
      else
	if detectCobble() then
		break
	end
	turtle.select(firstFilledSlot)
        success = turtle.placeDown()
      end
    end
end

-- rotate to desired direction
function rotateToDirection(desiredDirection)
  while direction ~= desiredDirection do
    left()
  end
end

-- save coordinates
function saveCoordinates()
  log("saving coordinates...")
  savedDirection = direction
  savedX = x
  savedY = y
  savedZ = z
end

-- go back to 0,0,0
function returnToOrigin()
  log("returning to disk drive...")

  local returnClearanceHeight = numberOfLayers - (savedY - roofHeight) + 1
  up(returnClearanceHeight)

  rotateToDirection(0)
  if savedY < 0 then
    fwd(math.abs(savedY))
  elseif savedY > 0 then
    bwd(math.abs(savedY))
  end

  if savedX < 0 then
    left()
    bwd(math.abs(savedX))
    right()
  elseif savedX > 0 then
    right()
    bwd(math.abs(savedX))
    left()
  end
  
  dwn(savedZ + returnClearanceHeight)

  return returnClearanceHeight
end

-- go back to saved coordinates 
function returnToSaved(clearanceHeight)
  log("returning to saved coordinates...")

  rotateToDirection(0)

  up(math.abs(savedZ) + clearanceHeight)

  if savedX < 0 then
    left()
    fwd(math.abs(savedX))
    right()
  elseif savedX > 0 then
    right()
    fwd(math.abs(savedX))
    left()
  end

  fwd(math.abs(savedY))
  dwn(clearanceHeight)

  rotateToDirection(savedDirection)
end

function refillInventory()
  log("restocking...")
  up(1)
  spin()

  while getFirstUsedSlot() == nil do
    log("checking is stock is empty...")
    for i=1,14 do
      turtle.select(i)
      turtle.suck(64)
    end

    if getFirstUsedSlot() == nil then
      log("stock is empty. sleeping for 30s...")
      sleep(30)
    else
      log("successfully restocked!")
    end
  end

    
  dwn(1)
  spin()
end

-- sign is either -1 or 1 to see if its going forward or backwards
function updateCoordinates(sign)
  if direction == 0 then
    y = y + sign
  elseif direction == 1 then
    x = x + sign
  elseif direction == 2 then
    y = y - sign
  elseif direction == 3 then
    x = x - sign
  end
end

function line(length)
  for i=1,length-1 do
    put()
    fwd(1)
  end
  put()
end

-- movement
function safeForward()
    while not turtle.forward() do sleep(1) end
    updateCoordinates(1)
end

function safeBackward()
    while not turtle.back() do sleep(1) end
    updateCoordinates(-1)
end

function safeUp()
    while not turtle.up() do 
	sleep(1); 
	turtle.digUp()
    end
    z = z + 1
end

function safeDown()
    while not turtle.down() do sleep(1) end
    z = z - 1
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

function wrapDirection()
  if direction < 0 then
    direction = 3
  end

  if direction > 3 then
    direction = 0
  end
end

function left()
  turtle.turnLeft()
  direction = direction - 1
  wrapDirection()
end

function right()
  turtle.turnRight()
  direction = direction + 1
  wrapDirection()
end

function spin()
  left()
  left()
end

function getFirstUsedSlot()
  log("getting first used block...")
  for i=1,14 do
    if turtle.getItemCount(i) > 0 then
      return i
    end
  end

  return nil
end

function buildQuadrant(columnRadius)
    log("quadrant recursion. current radius: " .. columnRadius)

    -- stoping condition/repositon for next quadrant
    if columnRadius < 3 then
      line(2)
      right()
      fwd(1)
      left()
      put()
      fwd(1)
      left()
      bwd(1)
      return
    end
    
    local fullThrees = columnRadius / 3
    local lastColumnSliceSize = columnRadius % 3

    -- build out full 3 blocks in a row
    for i=1,fullThrees-1 do
      line(3)
      up(1)
      fwd(1)
    end
    line(3)

    -- build last line
    if (lastColumnSliceSize > 0) then
      up(1)
      fwd(1)
      line(lastColumnSliceSize)
    end

    -- return to start
    bwd(columnRadius-1)
    dwn(fullThrees-1)
    if lastColumnSliceSize > 0 then
      dwn(1)
    end

    -- reposition for next column
    fwd(1)
    right()
    fwd(1)
    left()

    -- recursive call
    buildQuadrant(columnRadius - 1)
end

function buildFullStructure()
  log("building full structure...")
  for currentQuadrant=1,4 do
    buildQuadrant(radius)
  end
  up(numberOfLayers)
  fwd(radius)
  put()
  up(1)

  -- place lava
  turtle.select(lavaBucketSlot)
  log("placing lava...")
  turtle.placeDown()

  up(1)
  put()
  up(1)

  -- wait to place water
  turtle.select(waterBucketSlot)
  for i=1,lavaSpreadTime do
    log("waiting for lava to spread... " .. i .. "/" .. lavaSpreadTime .. "s")
    sleep(1)
  end

  -- place and recollect water
  turtle.placeDown()
  sleep(5)
  turtle.placeDown()
  sleep(5)

  dwn(1)
  turtle.digDown()
  dwn(1)
  
  -- recollect the lava
  turtle.select(lavaBucketSlot)
  turtle.placeDown()
  turtle.select(1)

  bwd(radius + buildingSeperation)
  dwn(numberOfLayers + 1)
end

-- main
function main()
    turtle.select(1)
    log("starting build...")
    getUserInput()

    fwd(buildingSeperation)
    up(roofHeight + 1)

    buildFullStructure()

    dwn(roofHeight + 1)

    log("build completed!")
end

main()
