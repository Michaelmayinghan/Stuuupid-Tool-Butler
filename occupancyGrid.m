% Create a 10x10 map with 1 cell/meter resolution
map = binaryOccupancyMap(10, 10, 1);

% Define an obstacle
setOccupancy(map, [3 3; 3 4; 3 5], 1);

% Visualize
show(map)

% Check if a specific point is occupied
xy = [3.5 3.5];
isOccupied = checkOccupancy(map, xy) % Returns 1
