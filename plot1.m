close
clc

plot(Position.longitude,Position.latitude);
figure(2);
plot(Position.Timestamp,Position.latitude, 'r');

x1 = round(Position.latitude(1),2);
x2 = round(Position.latitude(50),2);

if x1 == x2
    disp("Stop")
end




