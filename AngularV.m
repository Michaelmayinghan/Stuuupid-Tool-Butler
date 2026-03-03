close all
clc



% FIGURE 1: GPS track
figure(1)
plot(Position.longitude, Position.latitude, 'b');
hold on; grid on
xlabel('Longitude'); ylabel('Latitude');
title('GPS Track (with 4 negative-spin events)');



% FIGURE 2: Angular velocity Z only
t_all = datetime(AngularVelocity.Timestamp);

figure(2)
% plot(t_all, AngularVelocity.X, 'b'); hold on
% plot(t_all, AngularVelocity.Y, 'g');
plot(t_all, AngularVelocity.Z, 'r'); hold on
grid on
xlabel('Time'); ylabel('Angular velocity');
title('Angular Velocity (Z)');
legend('Z');



% Detect 4 major negative spikes in Z
t = datetime(AngularVelocity.Timestamp);
w = AngularVelocity.Z;

valid = ~isnan(w) & ~isnat(t);
t = t(valid);
w = w(valid);

% 1) sort by most negative values
[~, sortedIdx] = sort(w, 'ascend');

% 2) pick 4 separated indices
selectedIdx = [];
minSeparation = 200;  % adjust if needed

for i = 1:length(sortedIdx)
    cand = sortedIdx(i);

    if isempty(selectedIdx) || all(abs(cand - selectedIdx) > minSeparation)
        selectedIdx(end+1) = cand; %#ok<AGROW>
    end

    if numel(selectedIdx) == 4
        break
    end
end

% sort by time
selectedIdx = sort(selectedIdx);

eventTimes  = t(selectedIdx);
eventValues = w(selectedIdx);

% Mark the 4 points on Z plot
figure(2)
plot(eventTimes, eventValues, 'ko', 'MarkerFaceColor','k', 'MarkerSize', 8);
legend('Z','4 negative spikes');



% Match each spike to nearest GPS sample
tPos = datetime(Position.Timestamp);

lat = zeros(4,1);
lon = zeros(4,1);
posIdx = zeros(4,1);

for k = 1:4
    [~, idxClosest] = min(abs(tPos - eventTimes(k)));
    posIdx(k) = idxClosest;
    lat(k) = Position.latitude(idxClosest);
    lon(k) = Position.longitude(idxClosest);
end

result = table(selectedIdx(:), eventTimes(:), eventValues(:), posIdx(:), lat(:), lon(:), ...
    'VariableNames', {'AV_Index','AV_Time','OmegaZ','GPS_Index','Latitude','Longitude'});

disp(result);



% Mark the 4 points on GPS plot
figure(1)
plot(lon, lat, 'ro', 'MarkerSize', 10, 'MarkerFaceColor', 'r');
legend('Track','4 negative-spin events');