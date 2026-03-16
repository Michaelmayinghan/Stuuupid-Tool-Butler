
clc

disp(result)

remark = [
    "marshgate"
    "slide right"
    "marshgate to stadium ThorntonSt Bridge lower point"
    "water fountain left"
    "mid random point not close to the slide"
    "slide up"
    "bridge start from marshgate to ops"
    "bridgeend up from marshgate to ops"
    "aqua down"
    "aqua door"
    "aqua upper stairs"
    "water fountain right"
    "ice cream shop"
    "same as water fountain right overlaped unsure"
    "water fountain to stadium bridgeend"
    "stadium mid"
    "lower stadium down"
    "stadium souvenir shop"
    "lower stadium up"
    "marshgate to stadium ThorntonSt Bridge upper point"
    "slide left"
    "ops"
    "bridgeend low from marshgate to ops"
];

allP = table(result.Latitude, result.Longitude, remark, ...
    'VariableNames', {'Latitude', 'Longitude', 'Remark'});

disp(allP)

%% distinguish between key points and signal points

% indices of key points
keyIdx = [1 2 3 6 10 13 18 21 22];

% extract key points
keyP = allP(keyIdx, :);

% find remaining indices (signal points)
allIdx = 1:height(allP);
sigIdx = setdiff(allIdx, keyIdx);

% extract signal points
sigP = allP(sigIdx, :);

disp("Key Points:")
disp(keyP)

disp("Signal Points:")
disp(sigP)


%% correction

% The GPS measurement for the souvenir shop near the London Stadium is 
% inaccurate and lies far from its true location
% from google map: 51.53737492705889, -0.015488024790530292
keyP.Latitude(7) = 51.537;
keyP.Longitude(7) = -0.01549;











