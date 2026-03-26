function routeXY = routeRCToWorldXY(routeRC, mapRef, occGrid)
%ROUTERCTOWORLDXY Convert occupancy-grid row/col route points to lon/lat.
% Output is Nx2 as [lon, lat].

if isempty(routeRC)
    routeXY = zeros(0,2);
    return;
end

nRows = size(occGrid,1);
nCols = size(occGrid,2);

rows = routeRC(:,1);
cols = routeRC(:,2);

lon = mapRef.lonLeft + (cols - 1) ./ max(nCols - 1, 1) * (mapRef.lonRight - mapRef.lonLeft);
lat = mapRef.latTop  - (rows - 1) ./ max(nRows - 1, 1) * (mapRef.latTop - mapRef.latBottom);

routeXY = [lon, lat];
end
