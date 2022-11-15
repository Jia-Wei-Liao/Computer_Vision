clc; clear; close all;

global p;
global q;
global r;
global s;
global g;

p = 1;  q = 2;  r = 3;  s = 4;  g = 5;

image = imread('figure/lena.bmp');
binary_image = getBinaryImg(image);
down_sampling_image = getdownSampleImg(binary_image, 8);
thinning_image = getThinningImg(down_sampling_image);
imshow(uint8(thinning_image));
imwrite(thinning_image, 'figure/thinning_image.png');

%% function
function val = isSameImg(image1, image2)
val = true;
[m, n] = size(image1);

for i = 1:m
    for j = 1:n
        if image1(i, j) ~= image2(i, j)
            val = false;
            return
        end
    end
end

end


function binary_image = getBinaryImg(image)
[m, n] = size(image);
binary_image = zeros(m, n);

for i = 1:m
    for j = 1:n
        if image(i, j) >= 128
            binary_image(i, j) = 255;
        else
            binary_image(i, j) = 0;
        end
    end
end

end


function down_sampling_image = getdownSampleImg(image, down_size)
[m, n] = size(image);
dm = floor(m / down_size);
dn = floor(n / down_size);
down_sampling_image = zeros(dm, dn);

for i = 1:dm
    for j = 1:dn
        down_sampling_image(i, j) = image((i-1)*down_size+1, (j-1)*down_size+1);
    end
end

end


function is_bound = isBound(i, j, m, n)
is_bound = (1 <= i) && (i <= m) && (1 <= j) && (j <= n);

end


function pixel = getPixel(i, j, image)
[m, n] = size(image);

if isBound(i, j, m, n)
    pixel = image(i, j);
else
    pixel = 0;
end

end


function [x0, x1, x2, x3, x4] = get4Neighbor(i, j, image)
x0 = getPixel(i, j, image);
x1 = getPixel(i, j+1, image);
x2 = getPixel(i-1, j, image);
x3 = getPixel(i, j-1, image);
x4 = getPixel(i+1, j, image);

end


function [x0, x1, x2, x3, x4, x5, x6, x7, x8] = get8Neighbor(i, j, image)
[x0, x1, x2, x3, x4] = get4Neighbor(i, j, image);
x5 = getPixel(i+1, j+1, image);
x6 = getPixel(i-1, j+1, image);
x7 = getPixel(i-1, j-1, image);
x8 = getPixel(i+1, j-1, image);

end


function val = getYokoi_h(b, c, d, e)
global q;
global r;
global s;

if (b == c)
    if (d ~= b) || (e ~= b)
        val = q;
    elseif (d == b) && (e == b)
        val = r;
    end
else  % b ~= c
    val = s;
end

end


function val = getYokoi_f(a1, a2, a3, a4)
global q;
global r;

if (a1 == r) && (a2 == r) && (a3 == r) && (a4 == r)
    val = 5;
else
    val = (a1 == q) + (a2 == q) + (a3 == q) + (a4 == q);
end

end


function yokoi_image = getYokoiImg(image)

% x7 x2 x6
% x3 x0 x1
% x8 x4 x5

[m, n] = size(image);
yokoi_image = zeros(m, n);

for i = 1:m
    for j = 1:n
        if image(i, j) > 0
            [x0, x1, x2, x3, x4, x5, x6, x7, x8] = get8Neighbor(i, j, image);
            a0 = getYokoi_h(x0, x1, x6, x2);
            a1 = getYokoi_h(x0, x2, x7, x3);
            a2 = getYokoi_h(x0, x3, x8, x4);
            a3 = getYokoi_h(x0, x4, x5, x1);
            yokoi_image(i, j) = getYokoi_f(a0, a1, a2, a3);
        end
    end
end

end


function val = getPairRelationship_f(x0, x1, x2, x3, x4)
global q;
global p;

h_val = (x1 == 1) + (x2 == 1) + (x3 == 1) + (x4 == 1);
if (h_val < 1) || (x0 ~= 1)
    val = q;
else
    val = p;
end

end


function pair_relation_image = getPairRelationImg(image)
[m, n] = size(image);
pair_relation_image = zeros(m, n);

for i = 1:m
    for j = 1:n
        if image(i, j) > 0
            [x0, x1, x2, x3, x4] = get4Neighbor(i, j, image);
            pair_relation_image(i, j) = getPairRelationship_f(x0, x1, x2, x3, x4);
        end
    end
end
end


function val = getConnectedShrink_h(b, c, d, e)
if (b == c) && ((d ~= b) || (e ~= b))
    val = 1;
else
    val = 0;
end

end


function val = getConnectedShrink_f(a1, a2, a3, a4, x)
global g;

counter = (a1 == 1) + (a2 == 1) + (a3 == 1) + (a4 == 1);

if counter == 1
    val = g;
else
    val = x;
end

end


function connected_shrink_image = getConnectedShrinkImg(image, pair_relation_image)
global p;
global g;

[m, n] = size(image);
connected_shrink_image = image;

for i = 1:m
    for j = 1:n
        if connected_shrink_image(i, j) ~= 0
            [x0, x1, x2, x3, x4, x5, x6, x7, x8] = get8Neighbor(i, j, connected_shrink_image);
            a0 = getConnectedShrink_h(x0, x1, x6, x2);
            a1 = getConnectedShrink_h(x0, x2, x7, x3);
            a2 = getConnectedShrink_h(x0, x3, x8, x4);
            a3 = getConnectedShrink_h(x0, x4, x5, x1);
            connected_shrink_pixel = getConnectedShrink_f(a0, a1, a2, a3, x0);

            if (connected_shrink_pixel == g) && (pair_relation_image(i, j) == p)
                connected_shrink_image(i, j) = 0;
            end
        end
    end
end

end


function thinning_image = getThinningImg(image)
[m, n] = size(image);
pre_image = zeros(m, n);
thinning_image = image;

while ~isSameImg(thinning_image, pre_image)
    pre_image = thinning_image;
    yokoi_image = getYokoiImg(thinning_image);
    pair_relation_image = getPairRelationImg(yokoi_image);
    thinning_image = getConnectedShrinkImg(thinning_image, pair_relation_image);
end

end
