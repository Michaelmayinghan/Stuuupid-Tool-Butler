clc;
data = load('DSAWalkingAroundTheUCLTree.mat');

pos_x = data.Position.latitude;
pos_y = data.Position.longitude;

plot(pos_y,pos_x, 'r');