clear; clc;
data = load("MarshgateTest.mat");
geobasemap streets;
geoplot(data.Position.latitude, data.Position.longitude);