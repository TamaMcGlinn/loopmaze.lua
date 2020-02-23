math.randomseed( os.time() )
io.write("X size: ")
xCells = io.read()
io.write("Y size: ")
yCells = io.read()
xSize = xCells*2+1
ySize = yCells*2+1

world = {}
for x=1,xSize do
  world[x] = {}
  for y=1,ySize do
    world[x][y] = 1
  end
end
cellStack = {}

function dfs(neighbourfunction, start)
  local currentCel = start
  world[currentCel[1]][currentCel[2]] = 0
  local visitedCells = 1

  while currentCel ~= nil do
    newCel = neighbourfunction(currentCel[1],currentCel[2],visitedCells)
    if newCel ~= nil then
      world[newCel[1]][newCel[2]] = 0
      wall = average(currentCel, newCel)
      world[wall[1]][wall[2]] = 0
      cellStack[#cellStack+1] = currentCel
      currentCel = newCel
      visitedCells = visitedCells + 1
    else
      currentCel = cellStack[#cellStack]
      cellStack[#cellStack] = nil
    end
  end
end

function addNeighbours(list, x, y)
  if y < ySize-1 then
    if world[x][y+2] == 1 then
      list[#list+1] = {x,y+2}
    end
  end
  if x > 2 then
    if world[x-2][y] == 1 then
      list[#list+1] = {x-2,y}
    end
  end
  if y > 2 then
    if world[x][y-2] == 1 then
      list[#list+1] = {x,y-2}
    end
  end
  if x < xSize-1 then
    if world[x+2][y] == 1 then
      list[#list+1] = {x+2,y}
    end
  end
end

function allUnvisitedNeighbours(x,y,visitedCells)
  if visitedCells == xCells*yCells then
    return nil
  end
  local candidates = {}
  addNeighbours(candidates, x, y)
  if #candidates > 0 then
    return candidates[math.random(#candidates)]
  else
    return nil
  end
end

function average(cel1, cel2)
  return { (cel1[1] + cel2[1])/2, (cel1[2] + cel2[2])/2 }
end

function halfUnvisitedNeighbours(x,y,visitedCells)
  if visitedCells >= (xCells*yCells)/2 then
    return nil
  end
  candidates = {}
  addNeighbours(candidates, x, y)
  if #candidates > 0 then
    return candidates[math.random(#candidates)]
  else
    return nil
  end
end

function contains( list, elem )
  for i,item in ipairs(list) do
    if item[1] == elem[1] and item[2] == elem[2] then
      return 1
    end
  end
  return 0
end

function getBorders( cell )
  borders = {}
  todoQueue = { cell }
  progress = 1 --current item in queue
  while progress <= #todoQueue do
    local curr = todoQueue[progress]
    if curr[1] > 2 then
      if world[curr[1]-2][curr[2]] == 0 then --visited neighbour
	borders[#borders+1] = average( curr, { curr[1]-2, curr[2] } )
      elseif contains( todoQueue, { curr[1]-2, curr[2] } ) == 0 then
	todoQueue[#todoQueue+1] = { curr[1]-2, curr[2] }
      end
    end
    if curr[1] < xSize-1 then
      if world[curr[1]+2][curr[2]] == 0 then
	borders[#borders+1] = average( curr, { curr[1]+2, curr[2] } )
      elseif contains( todoQueue, { curr[1]+2, curr[2] } ) == 0 then
	todoQueue[#todoQueue+1] = { curr[1]+2, curr[2] }
      end
    end
    if curr[2] > 2 then
      if world[curr[1]][curr[2]-2] == 0 then
	borders[#borders+1] = average( curr, { curr[1], curr[2]-2 } )
      elseif contains( todoQueue, { curr[1], curr[2]-2 } ) == 0 then
	todoQueue[#todoQueue+1] = { curr[1], curr[2]-2 }
      end
    end
    if curr[2] < ySize-1 then
      if world[curr[1]][curr[2]+2] == 0 then
	borders[#borders+1] = average( curr, { curr[1], curr[2]+2 } )
      elseif contains( todoQueue, { curr[1], curr[2]+2 } ) == 0 then
	todoQueue[#todoQueue+1] = { curr[1], curr[2]+2 }
      end
    end
    progress = progress+1
  end
  return borders
end

start = {}
start[1] = math.random(xCells-2)*2 + 2
start[2] = math.random(yCells-2)*2 + 2
dfs(halfUnvisitedNeighbours, start)

for yi=2,ySize-1,2 do
  for xi=2,xSize-1,2 do
    if world[xi][yi] == 1 then
      borders = getBorders( {xi, yi} )
      firstexit_index = math.random(#borders)
      firstexit = borders[firstexit_index]
      secondexit_index = (firstexit_index + math.random(#borders-1)) % (#borders) + 1
      secondexit = borders[secondexit_index]
      world[firstexit[1]][firstexit[2]] = 0
      world[secondexit[1]][secondexit[2]] = 0
      dfs(allUnvisitedNeighbours, {xi, yi})
    end
  end
end

--exits:
world[2][1] = 0
world[xSize-1][ySize] = 0

while turtle.forward() == false do turtle.refuel(64) end

function refill(x,y,z)
  for i=z,2 do
    while turtle.up() == false do turtle.refuel(64) end
  end
  if x%2 == 1 then
    turtle.turnLeft()
  else
    turtle.turnRight()
  end
  for i=1,x-1 do
    while turtle.forward() == false do turtle.refuel(64) end
  end
  turtle.turnLeft()
  for i=1,y do
    while turtle.forward() == false do turtle.refuel(64) end
  end
  while turtle.down() == false do turtle.refuel(64) end
  while turtle.down() == false do turtle.refuel(64) end
  for i=1,16 do
    turtle.select(i)
    turtle.suckDown()
  end
  while turtle.up() == false do turtle.refuel(64) end
  while turtle.up() == false do turtle.refuel(64) end
  turtle.turnLeft()
  turtle.turnLeft()
  for i=1,y do
    while turtle.forward() == false do turtle.refuel(64) end
  end
  turtle.turnRight()
  for i=1,x-1 do
    while turtle.forward() == false do turtle.refuel(64) end
  end
  if x%2 == 1 then
    turtle.turnLeft()
  else
    turtle.turnRight()
  end
  for i=z,2 do
    while turtle.down() == false do turtle.refuel(64) end
  end
end

function safePlace(x,y,z)
  for i=1,16 do
    if turtle.getItemCount(i) > 0 then
      turtle.select(i)
      break
    elseif i == 16 then
      refill(x,y,z)
      turtle.select(1)
    end
  end
  while turtle.placeDown() == false do end
end

z=1
for x=1,xSize do
  yStart = 1
  yEnd = ySize
  yStep = 1
  if x%2 == 0 then
    yStart = ySize
    yEnd = 1
    yStep = -1
  end
  for y=yStart,yEnd,yStep do
    safePlace(x,y,z)
    if world[x][y] == 1 then
      while turtle.up() == false do turtle.refuel(64) end
      z=2
      safePlace(x,y,z)
      while turtle.up() == false do turtle.refuel(64) end
      z=3
      safePlace(x,y,z)
    end
    if y == yEnd then
      if x%2 == 1 then
	turtle.turnRight()
	while turtle.forward() == false do turtle.refuel(64) end
	turtle.turnRight()
      else
	turtle.turnLeft()
	while turtle.forward() == false do turtle.refuel(64) end
	turtle.turnLeft()
      end
    else
      while turtle.forward() == false do turtle.refuel(64) end
    end
    if world[x][y] == 1 then
      while turtle.down() == false do turtle.refuel(64) end
      while turtle.down() == false do turtle.refuel(64) end
      z=1
    end
  end
end
