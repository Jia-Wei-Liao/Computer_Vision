clc; clear; close all;

image = imread('figure/lena.bmp');

%% (a) Laplace Mask1 (0, 1, 0, 1, -4, 1, 0, 1, 0): 15
laplace_mask1 = [0 1 0; 1 -4 1; 0 1 0];
laplace1_image = laplae_operator(image, laplace_mask1, 15);
imwrite(laplace1_image, 'figure/laplace1.png');

%% (b) Laplace Mask2 (1, 1, 1, 1, -8, 1, 1, 1, 1)
laplace_mask2 = [1/3 1/3 1/3; 1/3 -8/3 1/3; 1/3 1/3 1/3];
laplace2_image = laplae_operator(image, laplace_mask2, 15);
imwrite(laplace2_image, 'figure/laplace2.png');

%% (c) Minimum variance Laplacian: 20
min_laplace_mask = [2/3 -1/3 2/3; -1/3 -4/3 -1/3; 2/3 -1/3 2/3];
min_laplace_image = laplae_operator(image, min_laplace_mask, 20);
imwrite(min_laplace_image, 'figure/min_laplace.png');

%% (d) Laplace of Gaussian: 3000
laplae_of_gaussian_mask = [
     0  0   0  -1  -1  -2  -1  -1   0  0  0;
     0  0  -2  -4  -8  -9  -8  -4  -2  0  0;
     0 -2  -7 -15 -22 -23 -22 -15  -7 -2  0;
    -1 -4 -15 -24 -14  -1 -14 -24 -15 -4 -1;
    -1 -8 -22 -14  52 103  52 -14 -22 -8 -1;
    -2 -9 -23  -1 103 178 103  -1 -23 -9 -2;
    -1 -8 -22 -14  52 103  52 -14 -22 -8 -1;
    -1 -4 -15 -24 -14  -1 -14 -24 -15 -4 -1;
     0 -2  -7 -15 -22 -23 -22 -15  -7 -2  0;
     0  0  -2  -4  -8  -9  -8  -4  -2  0  0;
     0  0   0  -1  -1  -2  -1  -1   0  0  0
     ];
laplae_of_gaussian_image = laplae_operator(image, laplae_of_gaussian_mask, 3000);
imwrite(laplae_of_gaussian_image, 'figure/laplace_of_gaussian.png');

%% (e) Difference of Gaussian: 1
difference_of_gaussian_mask = [
     -1  -3  -4  -6  -7  -8  -7  -6  -4  -3  -1;
	 -3  -5  -8 -11 -13 -13 -13 -11  -8  -5  -3;
	 -4  -8 -12 -16 -17 -17 -17 -16 -12  -8  -4;
	 -6 -11 -16 -16   0  15   0 -16 -16 -11  -6;
	 -7 -13 -17   0  85 160  85   0 -17 -13  -7;
	 -8 -13 -17  15 160 283 160  15 -17 -13  -8;
	 -7 -13 -17   0  85 160  85   0 -17 -13  -7;
	 -6 -11 -16 -16   0  15   0 -16 -16 -11  -6;
	 -4  -8 -12 -16 -17 -17 -17 -16 -12  -8  -4;
	 -3  -5  -8 -11 -13 -13 -13 -11  -8  -5  -3;
     -1  -3  -4  -6  -7  -8  -7  -6  -4  -3  -1
     ];
difference_of_gaussian_image = laplae_operator(image, difference_of_gaussian_mask, 1);
imwrite(difference_of_gaussian_image, 'figure/difference_of_gaussian.png');


%% function
function local_image = get_local_image(img, kernel, i, j)
[km, kn] = size(kernel);
local_image = zeros(km, kn);

for p = 1:km
    for q = 1:kn
        local_image(p, q) = img(i-1+p, j-1+q);
    end
end

end


function neighbor = get_neighbor(img, i, j, N)
neighbor = zeros(2*N+1, 2*N+1);
for p = -N:N
    for q = -N:N
        neighbor(N+1+p, N+1+q) = img(i+p, j+q);
    end
end

end


function value = convolution(image, kernel)
[m, n] = size(kernel);
value = 0;

for i = 1:m
    for j = 1:n
        value = value + image(i, j) * kernel(i, j);
    end
end
end


function out_image = laplae_operator(image, kernel, threshold)
[m, n] = size(image);
[km, kn] = size(kernel);
out_m = m - (km-1);
out_n = n - (kn-1);
image = double(image);
out_image = zeros(out_m, out_n);
[km, ~] = size(kernel);
pad_pixel = (km-1) / 2;

for i = 1:out_m
    for j = 1:out_n
        local_image = get_local_image(image, kernel, i, j);
        value = convolution(local_image, kernel);

        if value >= threshold
            out_image(i, j) = 1;
        elseif value <= -threshold
            out_image(i, j) = -1;
        else
            out_image(i, j) = 0;
        end
        
    end
end

out_image = zero_crossing(out_image, pad_pixel);
out_image = uint8(out_image);

end


function pad_img = padding(img, pad_piexl)
[m, n] = size(img);
pad_img = zeros(m + pad_piexl*2, n + pad_piexl*2);

for i = 1:m
    for j = 1:n
        pad_img(i+pad_piexl, j+pad_piexl) = img(i, j);
    end
end

end


function bool_val = is_value_in_array(array, value)
[m, n] = size(array);
bool_val = false;

for i = 1:m
    for j = 1:n
        if array(i, j) == value
            bool_val = true;
            return
        end
    end
end

end


function output = constant(m, n, v)
output = zeros(m, n);
for i = 1:m
    for j = 1:n
        output(i, j) = v;
    end
end
end


function out_image = zero_crossing(image, pad_pixel)
[m, n] = size(image);
out_image = constant(m, n, 255);
image = padding(image, pad_pixel);

for i = 1:m
    for j = 1:n
        neighbor = get_neighbor(image, i+pad_pixel, j+pad_pixel, 1);

        if image(i+pad_pixel, j+pad_pixel) == 1 && is_value_in_array(neighbor, -1)
            out_image(i, j) = 0;
        end
        
    end
end

end
