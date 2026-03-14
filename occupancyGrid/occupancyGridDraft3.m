close all;
clc;

%% Read image
img = imread('SateBW.jpg');

if ndims(img) == 3
    imgGray = rgb2gray(img);
else
    imgGray = img;
end

imgGray = im2double(imgGray);

%% Pixel-level occupancy
% Black = occupied
occPixel = imgGray < 0.5;

%% Grid settings
metersPerPixel = 0.36848;
cellSize_m = 3;
cellSize_px = cellSize_m / metersPerPixel;

[imgH, imgW] = size(occPixel);

nRows = floor(imgH / cellSize_px);
nCols = floor(imgW / cellSize_px);

occGrid = zeros(nRows, nCols);

%% Convert pixel map to grid map
for r = 1:nRows
    for c = 1:nCols

        rowStart = round((r-1)*cellSize_px) + 1;
        rowEnd   = min(round(r*cellSize_px), imgH);

        colStart = round((c-1)*cellSize_px) + 1;
        colEnd   = min(round(c*cellSize_px), imgW);

        patch = occPixel(rowStart:rowEnd, colStart:colEnd);

        % If enough pixels in this cell are occupied, mark the grid cell occupied
        occupiedFraction = sum(patch(:)) / numel(patch);

        if occupiedFraction > 0.3
            occGrid(r,c) = 1;
        end
    end
end

%% Show occupancy grid
figure;
imagesc(occGrid);
axis image;
colormap(gray);
colorbar;
title('Auto-detected Occupancy Grid');

%% Show grid over traced image
figure;
imshow(imgGray);
hold on;
title('Grid Overlay on Traced Map');

for c = 0:nCols
    x = c * cellSize_px;
    plot([x x], [0 imgH], 'y-', 'LineWidth', 0.3);
end

for r = 0:nRows
    y = r * cellSize_px;
    plot([0 imgW], [y y], 'y-', 'LineWidth', 0.3);
end

hold off;

%% Overlay occupied cells on image
figure;
imshow(imgGray);
hold on;
title('Occupied Cells Overlaid on Traced Map');

for r = 1:nRows
    for c = 1:nCols
        if occGrid(r,c) == 1
            x1 = (c-1) * cellSize_px;
            y1 = (r-1) * cellSize_px;

            rectangle('Position', [x1, y1, cellSize_px, cellSize_px], ...
                'FaceColor', [1 0 0 0.35], ...
                'EdgeColor', 'none');
        end
    end
end

hold off;

%% Save
save('occupancyGrid.mat', 'occGrid', 'cellSize_m', 'cellSize_px', ...
     'metersPerPixel', 'nRows', 'nCols');