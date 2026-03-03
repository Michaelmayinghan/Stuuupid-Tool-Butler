close all
clc

%% ===================== Extract Z spikes =====================
t = datetime(AngularVelocity.Timestamp);
w = AngularVelocity.Z;

valid = ~isnan(w) & ~isnat(t);
t = t(valid);
w = w(valid);

% Sort most negative values
[sortedVals, sortedIdx] = sort(w);   % ascending (most negative first)

selectedIdx = [];
minSeparation = 200;   % adjust if needed

for i = 1:length(sortedIdx)
    candidate = sortedIdx(i);

    if isempty(selectedIdx)
        selectedIdx(end+1) = candidate;
    else
        if all(abs(candidate - selectedIdx) > minSeparation)
            selectedIdx(end+1) = candidate;
        end
    end

    if length(selectedIdx) == 4
        break
    end
end

eventTimes = t(selectedIdx);

%% ===================== Match GPS =====================
tPos = datetime(Position.Timestamp);

lat = zeros(4,1);
lon = zeros(4,1);

for k = 1:4
    [~, idxClosest] = min(abs(tPos - eventTimes(k)));
    lat(k) = Position.latitude(idxClosest);
    lon(k) = Position.longitude(idxClosest);
end

%% ===================== Plot GPS and Mark Points =====================
figure(1)
plot(Position.longitude, Position.latitude, 'b'); 
hold on
grid on
xlabel('Longitude')
ylabel('Latitude')
title('GPS Track with 4 Spin Events')

% Mark the 4 spike locations
plot(lon, lat, 'ro', 'MarkerSize',10, 'MarkerFaceColor','r')

legend('Track','Spin Events')


close all
clc

t = datetime(AngularVelocity.Timestamp);
w = AngularVelocity.Z;

valid = ~isnan(w) & ~isnat(t);
t = t(valid);
w = w(valid);

%% ---- Step 1: Sort by most negative values ----
[sortedVals, sortedIdx] = sort(w);   % ascending (most negative first)

%% ---- Step 2: Pick 4 separated spikes ----
selectedIdx = [];
minSeparation = 200;   % adjust depending on sampling rate

for i = 1:length(sortedIdx)
    
    candidate = sortedIdx(i);
    
    if isempty(selectedIdx)
        selectedIdx(end+1) = candidate;
    else
        if all(abs(candidate - selectedIdx) > minSeparation)
            selectedIdx(end+1) = candidate;
        end
    end
    
    if length(selectedIdx) == 4
        break
    end
end

eventTimes  = t(selectedIdx);
eventValues = w(selectedIdx);

%% ---- Plot check ----
figure
plot(t, w, 'r'); hold on; grid on
plot(eventTimes, eventValues, 'ko', 'MarkerFaceColor','k')
xlabel('Time')
ylabel('\omega_z')
title('4 Major Negative Spikes')

%% ---- Get Corresponding GPS ----
tPos = datetime(Position.Timestamp);

lat = zeros(4,1);
lon = zeros(4,1);

for k = 1:4
    [~, idxClosest] = min(abs(tPos - eventTimes(k)));
    lat(k) = Position.latitude(idxClosest);
    lon(k) = Position.longitude(idxClosest);
end

result = table(eventTimes, lat, lon, ...
    'VariableNames', {'SpikeTime','Latitude','Longitude'});

disp(result)