clc; clear; close all;

img = imread('figure/lena.bmp');
imwrite(img, 'figure/image.png');

kernel = [0 1 1 1 0;
          1 1 1 1 1;
          1 1 1 1 1;
          1 1 1 1 1;
          0 1 1 1 0];

%% (a) Dilation
dilation_image = dilation(img, kernel);
figure();
imshow(dilation_image);
imwrite(dilation_image, 'figure/dilation_image.png');

%% (b) Erosion
erosion_image = erosion(img, kernel);
figure();
imshow(erosion_image);
imwrite(erosion_image, 'figure/erosion_image.png');

%% (c) Opening
opening_image = opening(img, kernel);
figure();
imshow(opening_image);
imwrite(opening_image, 'figure/opening_image.png');

%% (d) Closing
closing_image = closing(img, kernel);
figure();
imshow(closing_image);
imwrite(closing_image, 'figure/closing_image.png');


%% function
function matrix = costant_matrix(m, n, val)
matrix = zeros(m, n);

for i = 1:m
    for j = 1:n
        matrix(i, j) = val;
    end
end

end


function pad_img = padding(img, pad_piexl)
[m, n] = size(img);
pad_img = costant_matrix(m + pad_piexl*2, n + pad_piexl*2, -1);

for i = 1:m
    for j = 1:n
        pad_img(i+pad_piexl, j+pad_piexl) = img(i, j);
    end
end

end


function local_image = get_local_image(img, kernel, i, j)
[km, kn] = size(kernel);
local_image = zeros(km, kn);

for p = 1:km
    for q = 1:kn
        local_image(p, q) = img(i-1+p, j-1+q);
    end
end

end


function val = get_pixel(img, kernel, condition)
[km, kn] = size(kernel);
val = -1;

for i = 1:km
    for j = 1:kn
        if (img(i, j) >= 0) && (kernel(i, j) == 1)
            if (val == -1) || (condition(img(i, j), val))
                val = img(i, j);
            end
        end
    end
end

end


function dilation_image = dilation(img, kernel)
[m, n] = size(img);  [k, ~] = size(kernel);
dilation_image = zeros(m, n);
img = padding(img, floor(k / 2));
condition =@(pixel, val) pixel > val;

for i = 1:m
    for j = 1:n
        local_image = get_local_image(img, kernel, i, j);
        dilation_image(i, j) = get_pixel(local_image, kernel, condition);
    end
end

dilation_image = uint8(dilation_image);

end


function erosion_image = erosion(img, kernel)
[m, n] = size(img);  [k, ~] = size(kernel);
erosion_image = zeros(m, n);
img = padding(img, floor(k / 2));
condition =@(pixel, val) pixel < val;

for i = 1:m
    for j = 1:n
        local_image = get_local_image(img, kernel, i, j);
        erosion_image(i, j) = get_pixel(local_image, kernel, condition);
    end
end

erosion_image = uint8(erosion_image);

end


function opening_image = opening(img, kernel)
opening_image = erosion(img, kernel);
opening_image = dilation(opening_image, kernel);
opening_image = uint8(opening_image);

end


function closing_image = closing(img, kernel)
closing_image = dilation(img, kernel);
closing_image = erosion(closing_image, kernel);
closing_image = uint8(closing_image);

end
