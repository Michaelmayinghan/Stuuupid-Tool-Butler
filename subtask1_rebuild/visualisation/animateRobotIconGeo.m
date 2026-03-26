function animateRobotIconGeo(ax, routeXY, iconFile, scaleFactor)
%ANIMATEROBOTICONGEO Animate a robot icon in world lon/lat coordinates.

if isempty(routeXY)
    return;
end

[iconImg, ~, alpha] = imread(iconFile);
if isempty(alpha)
    if size(iconImg,3) == 3
        alpha = 255 * ones(size(iconImg,1), size(iconImg,2), 'uint8');
    else
        alpha = uint8(255 * (iconImg > 0));
    end
end

iconImg = imresize(iconImg, scaleFactor);
alpha   = imresize(alpha, scaleFactor);

xRange = diff(xlim(ax));
yRange = diff(ylim(ax));

% Scale icon footprint relative to current axes span.
iconW = max(1e-6, xRange * 0.03);
iconH = max(1e-6, yRange * 0.05);

lon = routeXY(1,1);
lat = routeXY(1,2);

xData = [lon - iconW/2, lon + iconW/2];
yData = [lat - iconH/2, lat + iconH/2];

hImg = image(ax, 'XData', xData, 'YData', yData, 'CData', iconImg, 'AlphaData', double(alpha)/255);
uistack(hImg, 'top');
drawnow;

for k = 2:size(routeXY,1)
    lon = routeXY(k,1);
    lat = routeXY(k,2);
    xData = [lon - iconW/2, lon + iconW/2];
    yData = [lat - iconH/2, lat + iconH/2];
    set(hImg, 'XData', xData, 'YData', yData);
    drawnow;
    pause(0.03);
end
end
