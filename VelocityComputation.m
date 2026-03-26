load('newMapReadings.mat');

% convert lat and lon to coordinates
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
t = seconds(timestamp-timestamp(1));

% velocity calculation
vx = gradient(x,t);
vy = gradient(y,t);
vz = gradient(z,t);

v = sqrt(vx.^2 + vy.^2 + vz.^2);

figure;

subplot(3,1,1)
plot(t, vx)
title('v_x')
grid on

subplot(3,1,2)
plot(t, vy)
title('v_y')
grid on

subplot(3,1,3)
plot(t, vz)
title('v_z')
grid on

figure;
plot(t, v)
title('Total Velocity')
grid on

% Filtering
% Savitzky-Golay

window = 11;
polyorder = 2;

vx_f = sgolayfilt(vx, polyorder, window);
vy_f = sgolayfilt(vy, polyorder, window);
vz_f = sgolayfilt(vz, polyorder, window);

figure;

subplot(3,1,1)
plot(t, vx, 'b'); hold on
plot(t, vx_f, 'r', 'LineWidth', 1.5)
title('v_x')
legend('Raw','Filtered')
grid on

subplot(3,1,2)
plot(t, vy, 'b'); hold on
plot(t, vy_f, 'r', 'LineWidth', 1.5)
title('v_y')
legend('Raw','Filtered')
grid on

subplot(3,1,3)
plot(t, vz, 'b'); hold on
plot(t, vz_f, 'r', 'LineWidth', 1.5)
title('v_z')
legend('Raw','Filtered')
grid on

