clc % don't clear

% Create a 10x10 map with 1 cell/meter resolution
map = binaryOccupancyMap(10, 10, 1);

% Define an obstacle
setOccupancy(map, [3 3; 3 4; 3 5], 1);

% Visualize
show(map)

% Check if a specific point is occupied
xy = [3 5];
xy = [3.5 5.5];
isOccupied = checkOccupancy(map, xy) % Returns 1

%% 

% 1. Load your satellite image
rgbImg = imread('handDrawnObstacles.jpg');

% 2. Segment the 'Obstacles' (e.g., Water and Buildings)
% We'll use grayscale as a shortcut, but you can also use color thresholds
grayImg = rgb2gray(rgbImg);

% 3. Define Real-World Scale
% You need to know the actual width of this area in meters.
% Let's assume the London Stadium is roughly 250 meters wide.
% If the stadium is 500 pixels wide in the image, resolution is 2 cells/meter.
imageWidthInPixels = size(rgbImg, 2);
realWorldWidthInMeters = 800; % Estimate for this view
res = imageWidthInPixels / realWorldWidthInMeters;

% 4. Create the Map
map = occupancyMap(double(obstacles), res);

% 5. Inflate for Safety
% If your robot is 2 meters wide, use a 1.1m radius to be safe
inflate(map, 1.1);

% 6. Visualize the result
figure;
subplot(1,2,1); imshow(rgbImg); title('Original Satellite View');
subplot(1,2,2); show(map); title('Converted Occupancy Map');

%% 


% 1. Load the yellow/white image
rawImg = imread('handDrawnObstacles.jpg');

% 2. Convert to binary
% Since the background is white [255, 255, 255] and the shapes are yellow,
% we can just look at the Blue channel. Yellow has very little blue.
blueChannel = rawImg(:,:,3); 
binaryGrid = blueChannel < 128; % Yellow areas become 1 (Occupied), White becomes 0 (Free)

% 3. Define Scale (Crucial!)
% Let's say this drawing represents a 20m x 20m room.
% If the image is 1000 pixels wide, resolution is 1000/20 = 50.
res = 50; 

% 4. Create the Map
map = occupancyMap(binaryGrid, res);

% 5. Visualize
show(map);
title('Occupancy Map from Manual Drawing');