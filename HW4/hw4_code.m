clc; clear; close all;

img = imread('figure/lena.bmp');
kernel = [0 1 1 1 0;
          1 1 1 1 1;
          1 1 1 1 1;
          1 1 1 1 1;
          0 1 1 1 0];

%% (a) a binary image (threshold at 128)
binary_image = generate_binary_image(img);
imshow(binary_image);
imwrite(binary_image, 'figure/binary_image.png');

%% (a) Dilation
dilation_image = dilation(binary_image, kernel);
figure();
imshow(dilation_image);
imwrite(dilation_image, 'figure/dilation_image.png');

%% (b) Erosion
erosion_image = erosion(binary_image, kernel);
figure();
imshow(erosion_image);
imwrite(erosion_image, 'figure/erosion_image.png');

%% (c) Opening
opening_image = opening(binary_image, kernel);
figure();
imshow(opening_image);
imwrite(opening_image, 'figure/opening_image.png');

%% (d) Closing
closing_image = closing(binary_image, kernel);
figure();
imshow(closing_image);
imwrite(closing_image, 'figure/closing_image.png');

%% (e) Hit-and-miss transform
J_kernel = [0 0 0 0 0;
            0 0 0 0 0;
            1 1 0 0 0;
            0 1 0 0 0;
            0 0 0 0 0];

K_kernel = [0 0 0 0 0;
            0 1 1 0 0;
            0 0 1 0 0;
            0 0 0 0 0;
            0 0 0 0 0];

hit_and_miss_image = hit_and_miss_transform( ...
    binary_image, J_kernel, K_kernel);
figure();
imshow(hit_and_miss_image);
imwrite(hit_and_miss_image, 'figure/hit_and_miss_image.png');

%% function
function binary_image = generate_binary_image(img)
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


function val = pixel_dilation(img, kernel)
[km, kn] = size(kernel);
val = 0;

for i = 1:km
    for j = 1:kn
        if img(i, j) >= 0
            if (kernel(i, j) == 1) && (img(i, j) == 255)
                val = 255;
                return
            end
        end
    end
end

end


function dilation_image = dilation(img, kernel)
[m, n] = size(img);  [k, ~] = size(kernel);
dilation_image = zeros(m, n);
img = padding(img, floor(k / 2));

for i = 1:m
    for j = 1:n
        local_image = get_local_image(img, kernel, i, j);
        dilation_image(i, j) = pixel_dilation(local_image, kernel);
    end
end

dilation_image = uint8(dilation_image);

end


function val = pixel_erosion(img, kernel)
[km, kn] = size(kernel);
val = 0;

for i = 1:km
    for j = 1:kn
        if img(i, j) >= 0
            if (kernel(i, j) == 1) && (img(i, j) ~= 255)
                return
            end
        end
    end
end

val = 255;

end


function erosion_image = erosion(img, kernel)
[m, n] = size(img);  [k, ~] = size(kernel);
erosion_image = zeros(m, n);
img = padding(img, floor(k / 2));

for i = 1:m
    for j = 1:n
        local_image = get_local_image(img, kernel, i, j);
        erosion_image(i, j) = pixel_erosion(local_image, kernel);
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


function img_c = complement(img)
[m, n] = size(img);
img_c = zeros(m, n);

for i = 1:m
    for j = 1:n
        if img(i, j) == 0
            img_c(i, j) = 255;
        end
    end
end

end


function img_inter = intersection(img1, img2)
[m, n] = size(img1);
img_inter = zeros(m, n);

for i = 1:m
    for j = 1:n
        if (img1(i, j) == 255) && (img2(i, j) == 255)
            img_inter(i, j) = 255;
        end
    end
end

end


function hit_and_miss_image = hit_and_miss_transform(img, J, K)
img_c = complement(img);
hit_and_miss_image = intersection(erosion(img, J), erosion(img_c, K));

end
