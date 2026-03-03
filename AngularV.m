close
clc % cannot clear

plot(Position.longitude,Position.latitude);
figure(2);
plot(AngularVelocity.Timestamp,AngularVelocity.X, 'b');
plot(AngularVelocity.Timestamp,AngularVelocity.Y, 'b');
% both dont work well

plot(AngularVelocity.Timestamp,AngularVelocity.Z, 'r');
% This Z is fine


figure(2)
plot(AngularVelocity.Timestamp, AngularVelocity.X, 'b')
hold on
plot(AngularVelocity.Timestamp, AngularVelocity.Y, 'g')
plot(AngularVelocity.Timestamp, AngularVelocity.Z, 'r')
hold off
legend('X','Y','Z')
grid on


class(AngularVelocity.Timestamp)










