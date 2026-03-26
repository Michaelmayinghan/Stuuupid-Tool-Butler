function L = createGraph_Dijkstra(nodes)

neighbors = {
    [10 17 11 8]                  % 1  Marshgate
    [10 17 13]                    % 2  OrbitMid
    [13 9 4]                      % 3  AquaticsDoor
    [3 9 15 5]                    % 4  IceCream
    [15 4 6]                      % 5  StadiumDoor
    [5 15 16]                     % 6  StadiumStore
    [12 13]                       % 7  OPS
    [1 16 17]                     % 8  Turn-MarshgateStadium
    [3 4 13]                      % 9  Splash
    [1 2 13]                      % 10 OrbitRight
    [1 12 7]                      % 11 MG-OPS-Bridge
    [11 7 13]                     % 12 Turn-OPS
    [2 3 7 9 10 14 17]            % 13 AquaticsBottom
    [13]                          % 14 AquaticsUpStairs
    [4 5 6 16]                    % 15 MID-Stadium
    [8 15 6]                      % 16 Stadium-MG-Bridge
    [1 2 8 13]                    % 17 OrbitLeft
};

coords = nodes.coords;
L = cell(length(neighbors),1);

for i = 1:length(neighbors)
    nb = neighbors{i};
    temp = zeros(length(nb),2);

    for k = 1:length(nb)
        j = nb(k);

        lat1 = coords(i,1);
        lon1 = coords(i,2);
        lat2 = coords(j,1);
        lon2 = coords(j,2);

        d = latlonDistanceMeters(lat1, lon1, lat2, lon2);

        temp(k,:) = [j, d];
    end

    L{i} = temp;
end

end


