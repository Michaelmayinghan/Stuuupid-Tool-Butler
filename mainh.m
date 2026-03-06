clc; close
data = load('DSAWalkingAroundTheUCLTree.mat');
data2 = load('firsttry.mat');
geobasemap streets

pos_x = data.Position.latitude;
pos_y = data.Position.longitude;
time1 = data.Position.Timestamp;

pos_x2 = data2.Position.latitude;
pos_y2 = data2.Position.longitude;
time2 = data2.Position.Timestamp;

geoplot(pos_x,pos_y, 'r');
hold on;
geoplot(pos_x2, pos_y2, 'g');

figure(2)
plot(time1,pos_x ,'r');
hold on;
plot(time2,pos_x2,'g');

% % disp(time)
% % disp(time2);
% % 
% % t = time1;
% % lat = pos_x;
% % 
% % sameAsPrev = lat == circshift(lat,1);
% % sameAsPrev(1) = false;
% % 
% % d = diff([false; sameAsPrev; false]);
% % runStarts = find(d == 1);
% % runEnds = find(d == -1) - 1;
% % 
% % durations = seconds(t(runEnds)-t(runStarts));
% % 
% % minDur = 8;
% % idx = durations >= minDur;
% % 
% % flatStarts = runStarts(idx);
% % flatEnds = runEnds(idx);
% % 
% % flatSegments = cell(sum(idx),1);
% % for k = 1:numel(flatStarts)
% %     flatSegments{k} = table(t(flatStarts(k):flatEnds(k)), lat(flatStarts(k):flatEnds(k)), 'VariableNames', {'Time', 'Latitude'});
% % end
% % 
% % figure(3)
% % plot(t, lat, 'b'); hold on;
% % 
% % for k = 1:numel(flatStarts)
% %     idxRange = flatStarts(k):flatEnds(k);
% %     plot(t(idxRange), lat(idxRange), 'r', 'LineWidth', 2);
% % end
% % 
% % title('Latitude with Flat Segments Highlighted');
% % xlabel('Time');
% % ylabel('Latitude');
% % 
% % 
% % for k = 1:numel(flatStarts)
% %     Coordinates of the stop
% %     lat_stop = pos_x(flatStarts(k));
% %     lon_stop = pos_y(flatStarts(k));
% % 
% %     Draw a circle marker
% %     plot(lon_stop, lat_stop, 'ko', ...
% %          'MarkerSize', 10, ...
% %          'LineWidth', 2, ...
% %          'MarkerFaceColor', 'y');
% % end
% % 
% % title('Latitude vs Longitude with Stops Marked');
% % xlabel('Longitude');
% % ylabel('Latitude');
% % grid on;




% clc; close all; clear;
% 
% %% Load data
% data  = load('DSAWalkingAroundTheUCLTree.mat');
% data2 = load('firsttry.mat');
% 
% %% Extract variables
% lat  = data.Position.latitude;
% lon  = data.Position.longitude;
% time = data.Position.Timestamp;
% 
% lat2 = data2.Position.latitude;
% lon2 = data2.Position.longitude;
% 
% %% Plot both paths
% figure(1)
% 
% hPath1 = plot(lon, lat, 'r', 'LineWidth', 1.5);
% hold on
% hPath2 = plot(lon2, lat2, 'g', 'LineWidth', 1.5);
% 
% xlabel('Longitude');
% ylabel('Latitude');
% title('Latitude vs Longitude');
% grid on
% 
% %% ------------------------------------------------------------
% % STOP DETECTION (Improved for 10 Hz GPS)
% %% ------------------------------------------------------------
% 
% R = 6371000; % Earth radius
% 
% % Convert to radians
% lat1  = deg2rad(lat(1:end-1));
% lat2s = deg2rad(lat(2:end));
% lon1  = deg2rad(lon(1:end-1));
% lon2s = deg2rad(lon(2:end));
% 
% % Haversine distance
% dlat = lat2s - lat1;
% dlon = lon2s - lon1;
% 
% a = sin(dlat/2).^2 + cos(lat1).*cos(lat2s).*sin(dlon/2).^2;
% c = 2 * atan2(sqrt(a), sqrt(1-a));
% dist = R * c;
% 
% %% Smooth GPS jitter (stronger smoothing for 10 Hz)
% dist_smooth = movmedian(dist, 11);
% 
% %% Movement threshold (important fix)
% movementThreshold = 1.5;   % meters (better for 10 Hz)
% 
% %% Detect stillness
% still = [false; dist_smooth < movementThreshold];
% 
% %% ------------------------------------------------------------
% % GAP FILLING
% %% ------------------------------------------------------------
% 
% gapSize = 5; % allow small GPS spikes (~0.5 s)
% 
% for i = 1:length(still)-gapSize-1
%     if still(i) && all(~still(i+1:i+gapSize)) && still(i+gapSize+1)
%         still(i+1:i+gapSize) = true;
%     end
% end
% 
% %% ------------------------------------------------------------
% % FIND STILLNESS SEGMENTS
% %% ------------------------------------------------------------
% 
% d = diff([false; still; false]);
% runStarts = find(d == 1);
% runEnds   = find(d == -1) - 1;
% 
% %% Compute durations
% durations = seconds(time(runEnds) - time(runStarts));
% 
% %% Stop classification
% purpleIdx = durations >= 70;
% blueIdx   = durations >= 50 & durations < 70;
% 
% purpleStarts = runStarts(purpleIdx);
% blueStarts   = runStarts(blueIdx);
% 
% %% ------------------------------------------------------------
% % MERGE NEARBY STOPS (important for your map result)
% %% ------------------------------------------------------------
% 
% mergeDistance = 6; % meters
% 
% keep = true(size(purpleStarts));
% 
% for i = 2:length(purpleStarts)
% 
%     latA = deg2rad(lat(purpleStarts(i-1)));
%     latB = deg2rad(lat(purpleStarts(i)));
%     lonA = deg2rad(lon(purpleStarts(i-1)));
%     lonB = deg2rad(lon(purpleStarts(i)));
% 
%     dlat = latB - latA;
%     dlon = lonB - lonA;
% 
%     a = sin(dlat/2).^2 + cos(latA).*cos(latB).*sin(dlon/2).^2;
%     c = 2 * atan2(sqrt(a), sqrt(1-a));
% 
%     distanceStops = R * c;
% 
%     if distanceStops < mergeDistance
%         keep(i) = false;
%     end
% end
% 
% purpleStarts = purpleStarts(keep);
% 
% %% ------------------------------------------------------------
% % PLOT STOPS
% %% ------------------------------------------------------------
% 
% hPurple = plot(lon(purpleStarts), lat(purpleStarts), 'mo', ...
%     'MarkerSize', 12, ...
%     'LineWidth', 2, ...
%     'MarkerFaceColor', 'm');
% 
% hBlue = plot(lon(blueStarts), lat(blueStarts), 'bo', ...
%     'MarkerSize', 10, ...
%     'LineWidth', 2, ...
%     'MarkerFaceColor', 'c');
% 
% %% Legend
% legend([hPath1 hPath2 hPurple hBlue], ...
%     'Path 1', ...
%     'Path 2', ...
%     'Stops >= 8s (Purple)', ...
%     'Stops 5–8s (Blue)');