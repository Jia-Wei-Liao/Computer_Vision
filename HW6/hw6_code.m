clc; clear; close all;

img = imread('figure/lena.bmp');

%% generate binary image (threshold at 128)
binary_image = generateBinaryImage(img);

%% generate down sampling image
down_sampling_image = downSampling(binary_image, 8);
% imshow(down_sampling_image);

%% implement yokoi algorithm
yokoiAlgorithm(down_sampling_image);

%% function
function binary_image = generateBinaryImage(img)
[m, n] = size(img);
binary_image = zeros(m, n);

for i = 1:m
    for j = 1:n
        if img(i, j) >= 128
            binary_image(i, j) = 255;
        else
            binary_image(i, j) = 0;
        end
    end
end

binary_image = uint8(binary_image);

end


function down_sampling_image = downSampling(img, down_size)
[m, n] = size(img);
dm = floor(m / down_size);
dn = floor(n / down_size);
down_sampling_image = zeros(dm, dn);

for i = 1:dm
    for j = 1:dn
        down_sampling_image(i, j) = img((i-1)*down_size+1, (j-1)*down_size+1);
    end
end

down_sampling_image = uint8(down_sampling_image);

end


function is_bound = isBound(i, j, m, n)
is_bound = (1 <= i) && (i <= m) && (1 <= j) && (j <= n); 
end

function pixel = getPixel(i, j, img)
[m, n] = size(img);
if isBound(i, j, m, n)
    pixel = img(i, j);
else
    pixel = 0;
end
end


function val = h(b, c, d, e)
if (b == c)
    if (d ~= b) || (e ~= b)
        val = 'q';
    elseif (d == b) && (e == b)
        val = 'r';
    end
else  % b ~= c
    val = 's';
end

end

function val = f(a1, a2, a3, a4)
if (a1 == a2) && (a1 == a3) && (a1 == a4) && (a1 == 'r')
    val = 5;
else
    val = (a1 == 'q') + (a2 == 'q') + (a3 == 'q') + (a4 == 'q');
end
end


function [] = yokoiAlgorithm(img)

% x7 x2 x6
% x3 x0 x1
% x8 x4 x5

[m, n] = size(img);
for i = 1:m
    for j = 1:n
        if img(i, j) == 0
            fprintf(' ');
            continue
        end
        
        % img(i, j) > 0
        x0 = getPixel(i, j, img);
        x1 = getPixel(i, j+1, img);
        x2 = getPixel(i-1, j, img);
        x3 = getPixel(i, j-1, img);
        x4 = getPixel(i+1, j, img);
        x5 = getPixel(i+1, j+1, img);
        x6 = getPixel(i-1, j+1, img);
        x7 = getPixel(i-1, j-1, img);
        x8 = getPixel(i+1, j-1, img);

        a0 = h(x0, x1, x6, x2);
        a1 = h(x0, x2, x7, x3);
        a2 = h(x0, x3, x8, x4);
        a3 = h(x0, x4, x5, x1);

        val = f(a0, a1, a2, a3);
        fprintf('%d', val);
    end
    fprintf('\n');
end

end
