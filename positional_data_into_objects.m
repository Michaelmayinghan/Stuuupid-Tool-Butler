% build_weighted_directed_nodes_with_dwell_labels.m
% - Collapses consecutive samples that are "the same place" (within radius)
% - Each stop/run becomes node (timestamp = start time of that stay)
% - Labels node as:
%     Signal  ~ around 6 seconds (within tolerance)
%     Key     >= 12
%     Normal  otherwise
% - Stores connections as array (usually 1 outgoing per node in a chain)
% - Adds loop: last node connects to first

clear; clc;

% Load
matPath = "DSAWalkingAroundTheUCLTree.mat";
S = load(matPath);
assert(isfield(S,"Position"), "MAT file does not contain variable 'Position'.");
P = S.Position;

disp("=== Position columns ===");
disp(P.Properties.VariableNames);

% Extract timestamp
t = [];
if istimetable(P)
    t = P.Properties.RowTimes;
end
if isempty(t)
    t = getVarCI(P, "Timestamp");
end
t_dt = toDatetime(t);

% Extract columns
lat  = getVarCI(P, "Latitude");
lon  = getVarCI(P, "Longitude");
alt  = getVarCI_optional(P, "Altitude");
spd  = getVarCI_optional(P, "Speed");
crs  = getVarCI_optional(P, "Course");
hacc = getVarCI_optional(P, "HAcc");

n = numel(lat);
assert(n >= 2, "Need at least 2 datapoints.");

% Parameters
samePlaceRadiusM = 3;     % how close = "same position"
signalTargetS    = 6;     % around 6 seconds
signalTolS       = 2;     % 6 +/- 2 seconds -> signal
keyThresholdS    = 12;    % >= 12 seconds -> key (change if you want)

% 1) Segment into "stays" (runs where you remain in the same place)
% We make a new segment when the distance from the segment's anchor point exceeds radius.

segStart = 1;
segLatAnchor = lat(1);
segLonAnchor = lon(1);

segStartIdx = [];
segEndIdx   = [];

for i = 2:n
    d = haversineMeters(segLatAnchor, segLonAnchor, lat(i), lon(i));
    if d > samePlaceRadiusM
        % close current segment
        segStartIdx(end+1,1) = segStart;
        segEndIdx(end+1,1)   = i-1;

        % start new segment
        segStart = i;
        segLatAnchor = lat(i);
        segLonAnchor = lon(i);
    end
end

% close final segment
segStartIdx(end+1,1) = segStart;
segEndIdx(end+1,1)   = n;

numSeg = numel(segStartIdx);

% 2) Build one node per segment
Nodes = table;
Nodes.TimestampStart = t_dt(segStartIdx);
Nodes.TimestampEnd   = t_dt(segEndIdx);

dwellS = seconds(Nodes.TimestampEnd - Nodes.TimestampStart);
dwellS(~isfinite(dwellS) | dwellS < 0) = 0;
Nodes.DwellSeconds = dwellS;

% Use mean position across the segment as the node position
Nodes.Latitude  = arrayfun(@(k) mean(lat(segStartIdx(k):segEndIdx(k)),'omitnan'), (1:numSeg)');
Nodes.Longitude = arrayfun(@(k) mean(lon(segStartIdx(k):segEndIdx(k)),'omitnan'), (1:numSeg)');

% Keep other data (mean across segment if present)
Nodes.Altitude = segMeanOrNaN(alt,  segStartIdx, segEndIdx);
Nodes.Speed    = segMeanOrNaN(spd,  segStartIdx, segEndIdx);
Nodes.Course   = segMeanOrNaN(crs,  segStartIdx, segEndIdx);
Nodes.HAcc     = segMeanOrNaN(hacc, segStartIdx, segEndIdx);

% 3) Label nodes based on dwell time
Nodes.Label = repmat("Normal", numSeg, 1);

isSignal = abs(Nodes.DwellSeconds - signalTargetS) <= signalTolS;
isKey    = Nodes.DwellSeconds >= keyThresholdS;

Nodes.Label(isSignal) = "Signal";
Nodes.Label(isKey)    = "Key";     % Key overrides Signal if both happen

% convenience booleans too
Nodes.IsSignal = isSignal;
Nodes.IsKey    = isKey;

% Build directed edges between nodes (segment-to-segment)
Nodes.ConnectsToTimestampsStart   = cell(numSeg,1);
Nodes.ConnectsFromTimestampsStart = cell(numSeg,1);

Nodes.DeltaTToNext           = cell(numSeg,1);
Nodes.DistanceToNext         = cell(numSeg,1);
Nodes.DirectionDegToNext     = cell(numSeg,1);

% Compute per-edge info between segment centroids
for i = 1:numSeg
    if i < numSeg
        j = i+1;
    else
        j = 1; % loop back
    end

    % timestamps used as node id
    toTs = Nodes.TimestampStart(j);
    Nodes.ConnectsToTimestampsStart{i} = toTs;

    % time between end of i and start of j
    dT = seconds(Nodes.TimestampStart(j) - Nodes.TimestampEnd(i));
    if ~isfinite(dT) || dT < 0
        dT = NaN;
    end
    Nodes.DeltaTToNext{i} = dT;

    % distance between node positions (meters)
    dM = haversineMeters(Nodes.Latitude(i), Nodes.Longitude(i), Nodes.Latitude(j), Nodes.Longitude(j));
    Nodes.DistanceToNext{i} = dM;

    % bearing degrees
    bD = bearingDeg(Nodes.Latitude(i), Nodes.Longitude(i), Nodes.Latitude(j), Nodes.Longitude(j));
    Nodes.DirectionDegToNext{i} = bD;
end

% incoming lists
for i = 1:numSeg
    Nodes.ConnectsFromTimestampsStart{i} = datetime.empty(0,1);
end

for i = 1:numSeg
    toTs = Nodes.ConnectsToTimestampsStart{i};
    j = find(Nodes.TimestampStart == toTs, 1);
    if ~isempty(j)
        Nodes.ConnectsFromTimestampsStart{j} = [Nodes.ConnectsFromTimestampsStart{j}; Nodes.TimestampStart(i)];
    end
end


nodeNames = string(Nodes.TimestampStart);
s = (1:numSeg)';
tIdx = [2:numSeg 1]'; % chain + loop
w = cellfun(@(x) x, Nodes.DistanceToNext);
G = digraph(s, tIdx, w, nodeNames);

assignin('base',"Nodes",Nodes);
assignin('base',"G",G);

disp("Done. Created Nodes (collapsed by stays) + digraph G.");
if usejava('desktop')
    try, openvar('Nodes'); catch, end
end

function v = getVarCI(T, wantedName)
    names = string(T.Properties.VariableNames);
    k = find(strcmpi(names, wantedName), 1);
    if isempty(k)
        error("Missing variable '%s'. Available: %s", wantedName, strjoin(names, ", "));
    end
    v = T.(names(k));
end

function v = getVarCI_optional(T, wantedName)
    names = string(T.Properties.VariableNames);
    k = find(strcmpi(names, wantedName), 1);
    if isempty(k)
        v = [];
    else
        v = T.(names(k));
    end
end

function out = segMeanOrNaN(arr, segStartIdx, segEndIdx)
    numSeg = numel(segStartIdx);
    if isempty(arr)
        out = NaN(numSeg,1);
        return;
    end
    out = zeros(numSeg,1);
    for k = 1:numSeg
        out(k) = mean(arr(segStartIdx(k):segEndIdx(k)),'omitnan');
    end
end

function dt = toDatetime(t)
    if isa(t,'datetime')
        dt = t; return;
    end
    if isnumeric(t)
        if median(t,'omitnan') > 1e12
            dt = datetime(t/1000,'ConvertFrom','posixtime','TimeZone','UTC'); % ms
        else
            dt = datetime(t,'ConvertFrom','posixtime','TimeZone','UTC');      % s
        end
        return;
    end
    dt = datetime(t,'TimeZone','UTC');
end

function d = haversineMeters(lat1, lon1, lat2, lon2)
    R = 6371000;
    phi1 = deg2rad(lat1); phi2 = deg2rad(lat2);
    dphi = deg2rad(lat2 - lat1);
    dl   = deg2rad(lon2 - lon1);
    a = sin(dphi/2).^2 + cos(phi1).*cos(phi2).*sin(dl/2).^2;
    c = 2 * atan2(sqrt(a), sqrt(1-a));
    d = R * c;
end

function b = bearingDeg(lat1, lon1, lat2, lon2)
    phi1 = deg2rad(lat1);  phi2 = deg2rad(lat2);
    dl   = deg2rad(lon2 - lon1);
    y = sin(dl).*cos(phi2);
    x = cos(phi1).*sin(phi2) - sin(phi1).*cos(phi2).*cos(dl);
    b = mod(rad2deg(atan2(y,x)) + 360, 360);

end
