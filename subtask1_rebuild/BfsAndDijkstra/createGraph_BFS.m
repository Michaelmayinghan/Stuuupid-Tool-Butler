function L = createGraph_BFS(nodes)

% Node numbering after combining [keyP; sigP]:
%
%  1  Marshgate
%  2  OrbitMid
%  3  AquaticsDoor
%  4  IceCream
%  5  StadiumDoor
%  6  StadiumStore
%  7  OPS
%  8  Turn-MarshgateStadium
%  9  Splash
% 10  OrbitRight
% 11  MG-OPS-Bridge
% 12  Turn-OPS
% 13  AquaticsBottom
% 14  AquaticsUpStairs
% 15  MID-Stadium
% 16  Stadium-MG-Bridge
% 17  OrbitLeft

neighbors = {
    [10 17 11 8]      % 1  Marshgate
    [10 17 13]        % 2  OrbitMid
    [13 9 4]          % 3  AquaticsDoor
    [3 9 15 5]        % 4  IceCream
    [15 4 6]          % 5  StadiumDoor
    [5 15 16]         % 6  StadiumStore
    [12 13]           % 7  OPS
    [1 16 17]         % 8  Turn-MarshgateStadium
    [3 4 13]          % 9  Splash
    [1 2 13]          % 10 OrbitRight
    [1 12 7]          % 11 MG-OPS-Bridge
    [11 7 13]         % 12 Turn-OPS
    [2 3 7 9 10 12 14 17]   % 13 AquaticsBottom
    [13]              % 14 AquaticsUpStairs
    [4 5 6 16]        % 15 MID-Stadium
    [8 15 6]          % 16 Stadium-MG-Bridge
    [1 2 8 13]        % 17 OrbitLeft
};

L = cell(length(neighbors),1);

for i = 1:length(neighbors)
    nb = neighbors{i};
    temp = zeros(length(nb),2);

    for k = 1:length(nb)
        temp(k,:) = [nb(k), 1];
    end

    L{i} = temp;
end

end