clc; clear; close all;

image = imread('figure/lena.bmp');
[m, n] = size(image);

%% Part1. Write a program to do the following requirement.
% (a) upside-down lena.bmp
% (b) right-side-left lena.bmp
% (c) diagonally flip lena.bmp

upside_down_image     = zeros(m, n);
right_side_left_image = zeros(m, n);
diagonally_flip_image = zeros(n, m);

for i = 1 : m
    for j = 1 : n
        upside_down_image(m-i+1, j)     = image(i, j);
        right_side_left_image(i, n-j+1) = image(i, j);
        diagonally_flip_image(j, i)     = image(i, j);
    end
end

upside_down_image     = uint8(upside_down_image);
right_side_left_image = uint8(right_side_left_image);
diagonally_flip_image = uint8(diagonally_flip_image);

% raw image
figure(1);  imshow(image);

figure(2);  imshow(upside_down_image);
imwrite(upside_down_image, 'figure/upside_down.png');

figure(3);  imshow(right_side_left_image);
imwrite(right_side_left_image, 'figure/right_side_left.png');

figure(4);  imshow(diagonally_flip_image);
imwrite(diagonally_flip_image, 'figure/diagonally_flip.png');

%% Part2. Write a program or use software to do the following requirement.
% (d) rotate lena.bmp 45 degrees clockwise
% (e) shrink lena.bmp in half
% (f) binarize lena.bmp at 128 to get a binary image

rotate_image = imrotate(image, -45);
figure(5); imshow(rotate_image);
imwrite(rotate_image, 'figure/rotate45.png');

shrink_in_half_image = imresize(image, [m/2, n/2]);
figure(6); imshow(shrink_in_half_image);
imwrite(shrink_in_half_image, 'figure/shrink_in_half.png');

binary_image = uint8(image > 128) * 255;
figure(7); imshow(binary_image);
imwrite(binary_image, 'figure/binary.png');
