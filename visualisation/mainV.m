close all;
clc;

basePath = '/Users/shanyuanluo/Documents/MATLAB/Year1/Term2/DSA/Stuuupid-Tool-Butler';
addpath(basePath);
addpath(fullfile(basePath, 'occupancyMap'));
addpath(fullfile(basePath, 'visualisation'));
addpath(fullfile(basePath, 'BfsAndDijkstra'));

load(fullfile(basePath, 'newMapReadings.mat'));

run('AngularV.m');
run('extractedPoints.m');

% Load occupancy grid data
load('occupancyGrid.mat', 'occGrid', 'cellSize_m', 'nRows', 'nCols');

% calibration bounds for the image
mapRef.latTop    = 51.5415;
mapRef.latBottom = 51.5370;
mapRef.lonLeft   = -0.0160;
mapRef.lonRight  = -0.0095;

% Build node structure
nodes = createNodesFromTables(keyP, sigP);

% Build weighted graph for Dijkstra
L_dij = createGraph_Dijkstra(nodes);

% Define waiting points
waitingIdx = getWaitingPointIndices(nodes);
waitingNames = string(nodes.names(waitingIdx));

% Randomly choose initial waiting point
rng('shuffle');
currentNode = waitingIdx(randi(numel(waitingIdx)));

fprintf('Robot is initially waiting at: %s\n', nodes.names{currentNode});
fprintf('Available waiting points: %s\n\n', strjoin(waitingNames, ", "));

% Ask for user input
fprintf('Available ALL points (key + signal):\n');
for i = 1:nodes.nTotal
    fprintf('%2d : %s\n', i, nodes.names{i});
end
fprintf('\n');

startName = input('Enter START point name: ', 's');
goalName  = input('Enter GOAL point name: ', 's');

startNode = findNodeByName(nodes, startName);
goalNode  = findNodeByName(nodes, goalName);



% 1) Go from current waiting point to chosen START point
[path_to_start_nodes, dist_to_start] = dijkstraShortestPath(L_dij, currentNode, startNode);

% 2) Go from START point to GOAL point
[path_to_goal_nodes, dist_to_goal] = dijkstraShortestPath(L_dij, startNode, goalNode);

% 3) After arrival, go to nearest waiting point
nearestWaitNode = nearestWaitingPoint(L_dij, waitingIdx, goalNode);
[path_to_wait_nodes, dist_to_wait] = dijkstraShortestPath(L_dij, goalNode, nearestWaitNode);

fprintf('\n===== ROUTES =====\n');
fprintf('Waiting -> Start distance: %.2f m\n', dist_to_start);
disp(nodes.names(path_to_start_nodes));

fprintf('\nStart -> Goal distance: %.2f m\n', dist_to_goal);
disp(nodes.names(path_to_goal_nodes));

fprintf('\nGoal -> Nearest Waiting distance: %.2f m\n', dist_to_wait);
disp(nodes.names(path_to_wait_nodes));

% Build detailed obstacle-free route on occupancy grid
fullRouteRC = [];

seg1 = buildDetailedRoute(path_to_start_nodes, nodes, mapRef, occGrid);
seg2 = buildDetailedRoute(path_to_goal_nodes, nodes, mapRef, occGrid);
seg3 = buildDetailedRoute(path_to_wait_nodes, nodes, mapRef, occGrid);

% Concatenate carefully to avoid duplicate rows
fullRouteRC = concatenateRoutes(seg1, seg2, seg3);

% Visualize map, graph, and animate robot
fig = figure('Name', 'Robot Navigation', 'Color', 'w');
ax = axes(fig);
plotOccupancyAndGraph(ax, occGrid, nodes, mapRef, L_dij, waitingIdx, currentNode, startNode, goalNode, nearestWaitNode);

% Highlight node-level Dijkstra routes
h1 = plotNodePath(ax, nodes, mapRef, occGrid, path_to_start_nodes, 'c-', 2.5);
h2 = plotNodePath(ax, nodes, mapRef, occGrid, path_to_goal_nodes, 'r-', 3.0);
h3 = plotNodePath(ax, nodes, mapRef, occGrid, path_to_wait_nodes, 'm-', 2.5);

set(h1, 'DisplayName', 'Waiting to start');
set(h2, 'DisplayName', 'Start to goal');
set(h3, 'DisplayName', 'Goal to waiting');


% Animate robot icon on detailed occupancy-grid route
animateRobotIcon(ax, fullRouteRC, 'igor.jpeg', 0.05);

% Final message
fprintf('\nSafely arrived from %s to %s\n', nodes.names{startNode}, nodes.names{goalNode});
fprintf('Robot returned to waiting point: %s\n', nodes.names{nearestWaitNode});








