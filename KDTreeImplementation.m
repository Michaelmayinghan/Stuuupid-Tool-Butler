% KD Tree implementation
clear; clc; 
% represent split_axis by 0 and 1 where 0 = x, 1 = y

split_axis = 0;

function [kdNode, split_axis] = createKdnode(xval, yval, split_axis)
    kdNode = struct("split_axis",split_axis,"xvalue",xval,"yvalue",yval,"left",[], "right", []);
    split_axis = ~split_axis;
end

function graph = insertKdnode(graph, kdNode)
    if isempty(graph)
        graph = kdNode; 
        return;
    end
    
    split_axis = kdNode.split_axis;
    
    if split_axis == 0
        if kdNode.xvalue < graph.xvalue
            graph.left = insertKdnode(graph.left, kdNode);
        else
            graph.right = insertKdnode(graph.right, kdNode);
        end
    else
        if kdNode.yvalue < graph.yvalue
            graph.left = insertKdnode(graph.left, kdNode);
        else
            graph.right = insertKdnode(graph.right, kdNode);
        end
    end
end

function plotKdTree(root)
    clf; 
    hold on;
    axis equal off;
    if isempty(root)
        return;
    end
    plotNode(root, 0, 0, 10);
end

function plotNode(node, x, y, dx)
    plot(x,y,'wo', 'MarkerFaceColor','y');
    text(x+0.3,y,sprintf('(%d,%d)',node.xvalue, node.yvalue));

    if ~isempty(node.left)
        xL = x - dx;
        yL = y - 5;
        plot([x, xL], [y, yL], 'w-');
        plotNode(node.left, xL, yL, dx/1.5);
    end

    if ~isempty(node.right)
        xR = x + dx;
        yR = y - 5;
        plot([x, xR], [y, yR], 'w-');
        plotNode(node.right, xR, yR, dx/1.5);
    end
end


points = [3 6; 17 15; 13 15; 6 12; 9 1; 2 7; 10 19];
graph = [];

for i = 1:size(points,1)
    xval = points(i, 1);
    yval = points(i, 2);

    [kdNode, split_axis] = createKdnode(xval, yval, split_axis);
    graph = insertKdnode(graph, kdNode);
end

plotKdTree(graph);


function plotKdSpace(node, xmin, xmax, ymin, ymax)
    if isempty(node)
        return;
    end

    hold on;

    if node.split_axis == 0
        % split on x
        x = node.xvalue;
        plot([x x], [ymin ymax], 'r-', 'LineWidth', 1.5);
        plot(x, node.yvalue, 'wo', 'MarkerFaceColor','y');

        plotKdSpace(node.left, xmin, x, ymin, ymax);
        plotKdSpace(node.right, x, xmax, ymin, ymax);
    else
        % split on y
        y = node.yvalue;
        plot([xmin xmax], [y y], 'b-', 'LineWidth', 1.5);
        plot(node.xvalue, y, 'wo', 'MarkerFaceColor','y');

        plotKdSpace(node.left, xmin, xmax, ymin, y);
        plotKdSpace(node.right, xmin, xmax, y, ymax);
    end
end

figure; hold on; axis equal;
plotKdSpace(graph, 0, 20, 0, 20);
legend('x-axis','points', 'y-axis');