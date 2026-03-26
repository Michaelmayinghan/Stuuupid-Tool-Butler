function out = mainV(varargin)
%MAINV Render the repo visualisation either standalone or inside a GUI axes.
% This version preserves the original mainV.m plotting style.

p = inputParser;
addParameter(p, 'axes', []);
addParameter(p, 'parent', []);
addParameter(p, 'ctx', []);
addParameter(p, 'showRoute', false);
addParameter(p, 'routePaths', {});
addParameter(p, 'routeColors', {});
addParameter(p, 'routeLabels', {});
addParameter(p, 'fullRouteRC', []);
addParameter(p, 'animate', false);
addParameter(p, 'title', 'Robot Navigation');
addParameter(p, 'currentNode', []);
addParameter(p, 'startNode', []);
addParameter(p, 'goalNode', []);
addParameter(p, 'nearestWaitNode', []);
parse(p, varargin{:});
opt = p.Results;

if isempty(opt.ctx)
    repoRoot = fileparts(fileparts(mfilename('fullpath')));
    addpath(genpath(repoRoot), '-begin');
    ctx = subtask1_build_context(repoRoot);
else
    if isfield(opt.ctx, 'basePath') && isfolder(opt.ctx.basePath)
        addpath(genpath(opt.ctx.basePath), '-begin');
    end
    ctx = opt.ctx;
end

ax = opt.axes;
if isempty(ax)
    if isempty(opt.parent)
        fig = figure('Name', 'Robot Navigation', 'Color', 'w');
        ax = axes(fig);
    else
        ax = axes('Parent', opt.parent);
    end
end

if isempty(opt.currentNode)
    opt.currentNode = ctx.waitingIdx(1);
end
if isempty(opt.startNode)
    opt.startNode = opt.currentNode;
end
if isempty(opt.goalNode)
    opt.goalNode = opt.startNode;
end

plotOccupancyAndGraph(ax, ctx.occGrid, ctx.nodes, ctx.mapRef, ctx.L_dij, ...
    ctx.waitingIdx, opt.currentNode, opt.startNode, opt.goalNode, opt.nearestWaitNode);
title(ax, opt.title);

routeHandles = gobjects(0);
if opt.showRoute && ~isempty(opt.routePaths)
    colors = opt.routeColors;
    labels = opt.routeLabels;
    if isempty(colors)
        colors = repmat({'r-'}, size(opt.routePaths));
    end
    if isempty(labels)
        labels = repmat({''}, size(opt.routePaths));
    end

    for i = 1:numel(opt.routePaths)
        if isempty(opt.routePaths{i})
            continue;
        end
        h = plotNodePath(ax, ctx.nodes, ctx.mapRef, ctx.occGrid, opt.routePaths{i}, colors{i}, 2.5);
        if ~isempty(h) && i <= numel(labels) && ~isempty(labels{i})
            set(h, 'DisplayName', labels{i});
        end
        routeHandles(end+1) = h; %#ok<AGROW>
    end
    legend(ax, 'Location', 'eastoutside');
end

if opt.animate && ~isempty(opt.fullRouteRC)
    iconPath = fullfile(ctx.basePath, 'visualisation', 'igor.jpeg');
    if exist(iconPath, 'file') == 2
        animateRobotIcon(ax, opt.fullRouteRC, iconPath, 0.05);
    end
end

out = struct();
out.ax = ax;
out.ctx = ctx;
out.routeHandles = routeHandles;
out.fullRouteRC = opt.fullRouteRC;
end
