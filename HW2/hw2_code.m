clc; clear; close all;

img = imread('figure/lena.bmp');
[m, n] = size(img);

%% (a) a binary image (threshold at 128)
binary_img = zeros(m, n);
for i = 1:m
    for j = 1:n
        if img(i, j) >= 128
            binary_img(i, j) = 255;
        else
            binary_img(i, j) = 0;
        end
    end
end

binary_img = uint8(binary_img);

figure(1);
imshow(binary_img);
imwrite(binary_img, 'figure/binary_image.png');

%% (b) a histogram
img_hist = zeros(1, 255);

for g = 1:255
    for i = 1:m
        for j = 1:n
            if img(i, j) == g
                img_hist(1, g) = img_hist(1, g) + 1;
            end
        end
    end
end

figure(2);
bar(img_hist);
grid on;
set(gcf);
saveas(gcf, 'figure/image_histogram.png');

%% (c) connected components (regions with + at centroid, bounding box)
linked = {};
next_label = 1;
labels = zeros(m, n);
n_connected = 4;

% First pass
for i = 1:m
    for j = 1:n
        if binary_img(i, j) > 0
            neighbor_labels = getNeightborLab(i, j, labels, n_connected);
            if isempty(neighbor_labels)
                labels(i, j) = next_label;
                linked{next_label} = [next_label];
                next_label = next_label + 1;
            else
                labels(i, j) = min(neighbor_labels);                
                for k = neighbor_labels
                    for l = neighbor_labels
                        if k ~= l
                            linked{k} = union(linked{k}, linked{l});
                        end
                    end
                end
            end
        end
    end
end

for i = 1:length(linked)
    for j = linked{i}
        linked{i} = union(linked{i}, linked{j});
    end
end

% Second pass
for i = 1:m
    for j = 1:n
        if labels(i, j) > 0
            labels(i, j) = min(linked{labels(i, j)});
        end
    end
end

% Compute the area of connected componets
large_label = max(labels, [], "all");
componets_area = zeros(1, large_label);

for i = 1:m
    for j = 1:n
        if labels(i, j) > 0
            componets_area(labels(i, j)) = componets_area(labels(i, j)) + 1;
        end
    end
end

% Omit regions that have a pixel count less than 500
label_thres = [];
for i = 1:large_label
    if componets_area(i) > 500
        label_thres(end+1) = i;
    end
end

%% Generate bounding boxes
bbox = zeros(length(label_thres), 6) ;
for i = 1:length(label_thres)
    bbox(i, :) = [m 1 n 1 0 0];
    % min_row, max_row, min_col, max_col center_row center_col
end

for i = 1:m
    for j = 1:n
        for k = 1:length(label_thres)
            if labels(i, j) == label_thres(k)
                area = componets_area(label_thres(k));
                bbox(k, 1) = min(i, bbox(k, 1));     % min_row
                bbox(k, 2) = max(i, bbox(k, 2));     % max_row
                bbox(k, 3) = min(j, bbox(k, 3));     % min_col
                bbox(k, 4) = max(j, bbox(k, 4));     % max_col
                bbox(k, 5) = bbox(k, 5) + i / area;  % center_row
                bbox(k, 6) = bbox(k, 6) + j / area;  % center_col
            end
        end
    end
end

figure(3);
imshow(labels);
hold on;

% Plot bounding boxes and centroid
for i = 1:length(label_thres)
    x0 = bbox(i, 3); y0 = bbox(i, 1);
    delta_x = bbox(i, 4) - bbox(i, 3);
    delta_y = bbox(i, 2) - bbox(i, 1);
    xc = bbox(i, 6); yc = bbox(i, 5);
    rectangle('Position', [x0 y0 delta_x delta_y], ...
        'EdgeColor', 'r', 'LineWidth', 1.5)
    plot(xc, yc, '+', 'Color', 'b', 'LineWidth', 1.5)
end
set(gcf);
saveas(gcf, ...
    ['figure/', num2str(n_connected), '_connected_components_image.png']);

%% fuction
function is_bound = isBound(i, j, m, n)
is_bound = (1 <= i) && (i <= m) && (1 <= j) && (j <= n); 
end


function [pixel] = getBoundLab(loc, labels)
[m, n] = size(labels);
if isBound(loc(1), loc(2), m, n) && labels(loc(1), loc(2)) > 0
    pixel = [labels(loc(1), loc(2))];
else
    pixel = [];
end
end


function [neighbor] = getNeightborLab(i, j, labels, n_connected)
switch n_connected
    case 4
        connect_set = {[i-1, j], [i, j-1]};
    case 8
        connect_set = {[i-1, j-1], [i-1, j], [i-1, j+1], [i, j-1]};
end
neighbor = [];

for k = 1:length(connect_set)
    loc = connect_set{k};
    pixel = getBoundLab(loc, labels);
    if ~isempty(pixel)
        neighbor(end+1) = pixel;
    end
end
end

