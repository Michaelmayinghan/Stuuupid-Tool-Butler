load('newMapReadings.mat');

% convert lat and lon to local coordinates
lat = deg2rad(Position.latitude);
lon = deg2rad(Position.longitude);
altitude = Position.altitude;

lat0 = lat(1);
lon0 = lon(1);
h0 = altitude(1);

R = 6371000;
x = R * (lon - lon0) .* cos(lat0);
y = R * (lat - lat0);
z = altitude - h0;

timestamp = Position.Timestamp;
t = seconds(timestamp - timestamp(1));

%% Velocity calculation
vx = gradient(x, t);
vy = gradient(y, t);
vz = gradient(z, t);

%% Smoothing using Savitzky-Golay filter
window = 11;
polyorder = 2;

vx_f = sgolayfilt(vx, polyorder, window);
vy_f = sgolayfilt(vy, polyorder, window);
vz_f = sgolayfilt(vz, polyorder, window);

% Smoothed speed magnitude
v_f = sqrt(vx_f.^2 + vy_f.^2 + vz_f.^2);

% Smoothed acceleration from smoothed speed
a_f = gradient(v_f, t);
a_f = sgolayfilt(a_f, polyorder, window);

% Smoothed turning rate
course_rad = unwrap(deg2rad(Position.course));
course_f = sgolayfilt(course_rad, polyorder, window);
turn_rate_f = gradient(course_f, t);
turn_rate_f = sgolayfilt(turn_rate_f, polyorder, window);

%% Remove unrealistic spikes first
mask = v_f <= 3.5;

t_masked         = t(mask);
v_masked         = v_f(mask);
a_masked         = a_f(mask);
turn_rate_masked = turn_rate_f(mask);

%% Thresholds
v_stop_th = 0.2;   % below this = stop
v_slow_th = 0.8;   % slow walking
v_fast_th = 1.5;   % fast movement
a_acc_th  = 0.5;   % accelerating threshold
turn_th   = 0.3;   % turning threshold (rad/s)

%% Pattern detection using smoothed data
N = length(t_masked);
state_masked = strings(N,1);

for i = 1:N
    if v_masked(i) < v_stop_th
        state_masked(i) = "Stop";

    elseif abs(turn_rate_masked(i)) > turn_th
        state_masked(i) = "Turning";

    elseif a_masked(i) > a_acc_th
        state_masked(i) = "Accelerating";

    elseif v_masked(i) > v_fast_th
        state_masked(i) = "Fast";

    elseif v_masked(i) < v_slow_th
        state_masked(i) = "Slow walk";

    else
        state_masked(i) = "Normal";
    end
end

%% Plot results
figure;
plot(t_masked, v_masked, 'k', 'LineWidth', 1); hold on

idx_stop = state_masked == "Stop";
idx_slow = state_masked == "Slow walk";
idx_fast = state_masked == "Fast";
idx_acc  = state_masked == "Accelerating";
idx_turn = state_masked == "Turning";

plot(t_masked(idx_stop), v_masked(idx_stop), 'ro', 'DisplayName', 'Stop')
plot(t_masked(idx_slow), v_masked(idx_slow), 'go', 'DisplayName', 'Slow walk')
plot(t_masked(idx_fast), v_masked(idx_fast), 'mo', 'DisplayName', 'Fast')
plot(t_masked(idx_acc),  v_masked(idx_acc),  'co', 'DisplayName', 'Accelerating')
plot(t_masked(idx_turn), v_masked(idx_turn), 'yo', 'DisplayName', 'Turning')

xlabel('Time (s)')
ylabel('Velocity (m/s)')
title('Pattern Detection Based on Smoothed Data')
legend('Smoothed Velocity', 'Stop', 'Slow walk', 'Fast', 'Accelerating', 'Turning')
grid on



























