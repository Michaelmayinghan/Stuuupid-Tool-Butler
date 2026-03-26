function plotOccupancyAndGraph(ax, occGrid, nodes, mapRef, ~, waitingIdx, currentNode, startNode, goalNode, nearestWaitNode)
% Plot occupancy map and markers only - NO graph edges.

axes(ax);
cla(ax);
hold(ax, 'on');

imagesc(ax, occGrid);
axis(ax, 'image');
set(ax, 'XDir', 'normal');
set(ax, 'YDir', 'reverse');

colormap(ax, [1 1 1; 0 0.6 0]);
caxis(ax, [0 1]);

title(ax, 'Occupancy Grid + Route');
xlabel(ax, 'Grid Column');
ylabel(ax, 'Grid Row');

for i = 1:nodes.nTotal
    [r, c] = latlonToGridRC(nodes.coords(i,1), nodes.coords(i,2), mapRef, occGrid);
    if i <= nodes.nKey
        plot(ax, c, r, 'ro', 'MarkerFaceColor', 'r', 'MarkerSize', 6, 'HandleVisibility', 'off');
    else
        plot(ax, c, r, 'bo', 'MarkerFaceColor', 'b', 'MarkerSize', 5, 'HandleVisibility', 'off');
    end
    text(ax, c+1, r, nodes.names{i}, 'FontSize', 8, 'Color', 'k');
end

plot(ax, nan, nan, 'ro', 'MarkerFaceColor', 'r', 'MarkerSize', 6, 'DisplayName', 'Key point');
plot(ax, nan, nan, 'bo', 'MarkerFaceColor', 'b', 'MarkerSize', 5, 'DisplayName', 'Signal point');

for idx = waitingIdx(:)'
    [r, c] = latlonToGridRC(nodes.coords(idx,1), nodes.coords(idx,2), mapRef, occGrid);
    plot(ax, c, r, 'gs', 'MarkerFaceColor', 'g', 'MarkerSize', 9, 'HandleVisibility', 'off');
end
plot(ax, nan, nan, 'gs', 'MarkerFaceColor', 'g', 'MarkerSize', 9, 'DisplayName', 'Waiting point');

if ~isempty(currentNode)
    [r, c] = latlonToGridRC(nodes.coords(currentNode,1), nodes.coords(currentNode,2), mapRef, occGrid);
    plot(ax, c, r, 'ms', 'MarkerFaceColor', 'm', 'MarkerSize', 12, 'DisplayName', 'Initial waiting');
end
if ~isempty(startNode)
    [r, c] = latlonToGridRC(nodes.coords(startNode,1), nodes.coords(startNode,2), mapRef, occGrid);
    plot(ax, c, r, 'co', 'MarkerFaceColor', 'c', 'MarkerSize', 10, 'DisplayName', 'Start');
end
if ~isempty(goalNode)
    [r, c] = latlonToGridRC(nodes.coords(goalNode,1), nodes.coords(goalNode,2), mapRef, occGrid);
    plot(ax, c, r, 'yo', 'MarkerFaceColor', 'y', 'MarkerSize', 10, 'DisplayName', 'Goal');
end
if ~isempty(nearestWaitNode)
    [r, c] = latlonToGridRC(nodes.coords(nearestWaitNode,1), nodes.coords(nearestWaitNode,2), mapRef, occGrid);
    plot(ax, c, r, 'kd', 'MarkerFaceColor', 'k', 'MarkerSize', 10, 'DisplayName', 'Return waiting');
end

legend(ax, 'Location', 'eastoutside');
end
