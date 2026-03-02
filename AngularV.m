close
clc % cannot clear

plot(Position.longitude,Position.latitude);
figure(2);
plot(AngularVelocity.Timestamp,AngularVelocity.X, 'b');
plot(AngularVelocity.Timestamp,AngularVelocity.Y, 'b');
% both dont work well

plot(AngularVelocity.Timestamp,AngularVelocity.Z, 'r');
% This Z is fine











