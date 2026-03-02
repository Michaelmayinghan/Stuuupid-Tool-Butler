clc; clear;

data = load("C:\Users\rohan\OneDrive\Desktop\UCL Projects\Year 1 DSA project 1\DSAWalkingAroundTheUCLTree.mat");

pos_x = data.Position.latitude;
pos_y = data.Position.longitude;

coords = [pos_x(:), pos_y(:)];

% -------- 1) Build grid edges + occupancy map FIRST --------
res = 0.0001; 
latEdges = (min(coords(:,1)) - res) : res : (max(coords(:,1)) + res);
lonEdges = (min(coords(:,2)) - res) : res : (max(coords(:,2)) + res);

[counts, ~, ~] = histcounts2(coords(:,1), coords(:,2), latEdges, lonEdges);
map = counts;  % occupancy map (rows=lat bins, cols=lon bins)

[nRows, nCols] = size(map);
numNodes = nRows * nCols;

nodeId = @(r,c) (c-1)*nRows + r;

% -------- 2) Convert coords -> grid indices --------
rowIdx = discretize(coords(:,1), latEdges);   % latitude -> row bin
colIdx = discretize(coords(:,2), lonEdges);   % longitude -> col bin

valid = ~isnan(rowIdx) & ~isnan(colIdx);
rowIdx = rowIdx(valid);
colIdx = colIdx(valid);

seqNodes = nodeId(rowIdx, colIdx);

% Remove consecutive duplicates (standing still in same cell)
keep = [true; diff(seqNodes) ~= 0];
seqNodes = seqNodes(keep);

% -------- 3) Build edge traversal counts (undirected) --------
edgeMap = containers.Map('KeyType','char','ValueType','any');

for k = 1:(numel(seqNodes)-1)
    u = seqNodes(k);
    v = seqNodes(k+1);

    % undirected: store in sorted order
    a = min(u,v);
    b = max(u,v);
    key = sprintf('%d_%d', a, b);

    if edgeMap.isKey(key)
        e = edgeMap(key);
        e.weight = e.weight + 1;
        e.traversals(end+1) = k;
        edgeMap(key) = e;
    else
        e = struct();
        e.u = a;
        e.v = b;
        e.weight = 1;          % traversals
        e.traversals = k;
        edgeMap(key) = e;
    end
end

keysList = edgeMap.keys;
m = numel(keysList);

s = zeros(m,1);
t = zeros(m,1);
w = zeros(m,1);
edgeStructs = cell(m,1);

for i = 1:m
    e = edgeMap(keysList{i});
    s(i) = e.u;
    t(i) = e.v;
    w(i) = e.weight;
    e.cost = 1 / e.weight;    % higher traversal => lower cost
    edgeStructs{i} = e;
end

costs = 1 ./ w;

% -------- 4) Build MATLAB graph --------
G = graph(s, t, costs, numNodes);

edgeTable = table(s, t, costs, w, 'VariableNames', ...
    {'EndNodes1','EndNodes2','Cost','TraversalCount'});
edgeTable.EdgeStruct = edgeStructs;

graphObj = G;
graphEdges = edgeTable;

fprintf('Constructed graph with %d nodes and %d edges.\n', numNodes, numedges(G));

% -------- 5) Plot occupancy map --------
figure;
imagesc(lonEdges(1:end-1), latEdges(1:end-1), map);
set(gca,'YDir','normal');
xlabel('Longitude'); ylabel('Latitude');
title('Occupancy map (point counts per grid cell)');
colorbar;

% -------- 6) Quick stats --------
fprintf('\nFirst 10 coordinate pairs (lat, lon):\n');
disp(coords(1:min(10,size(coords,1)), :));

fprintf('Total points in map (sum of counts): %d\n', sum(map(:)));
fprintf('Map max cell count: %d\n', max(map(:)));
fprintf('Map min cell count: %d\n', min(map(:)));
fprintf('Map mean cell count: %.3f\n', mean(map(:)));