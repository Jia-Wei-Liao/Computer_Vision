clc; clear; close all;

image = imread('figure/lena.bmp');

% (a) Generate noisy images with gaussian noise (amplitude of 10 and 30)
gaussian_noise_10_image = generate_gaussian_noise(image, 10);
gaussian_noise_30_image = generate_gaussian_noise(image, 30);

% (b) Generate noisy images with salt-and-pepper noise (probability 0.1 and 0.05)
salt_and_pepper_noise_0p1_image = generate_salt_and_pepper_noise(image, 0.1);
salt_and_pepper_noise_0p05_image = generate_salt_and_pepper_noise(image, 0.05);


%% Denoising
generate_noise_image_and_denoising_image( ...
    image, gaussian_noise_10_image, 'gaussian with amplitude of 10');
generate_noise_image_and_denoising_image( ...
    image, gaussian_noise_30_image, 'gaussian with amplitude of 30');
generate_noise_image_and_denoising_image( ...
    image, salt_and_pepper_noise_0p1_image, 'salt and pepper with probability of 0.1');
generate_noise_image_and_denoising_image( ...
    image, salt_and_pepper_noise_0p05_image, 'salt and pepper with probability of 0.05');

%% function
function noise_image = generate_gaussian_noise(image, amplitude)
[m, n] = size(image);
noise_image = zeros(m, n);

for i = 1:m
    for j = 1:n
        noise_image(i, j) = image(i, j) + amplitude * randn();
    end
end

noise_image = uint8(noise_image);

end


function noise_image = generate_salt_and_pepper_noise(image, prob)
[m, n] = size(image);
noise_image = zeros(m, n);

for i = 1:m
    for j = 1:n
        random_prob = rand();
        if random_prob < prob
            noise_image(i, j) = 0;
        elseif random_prob > 1 - prob
            noise_image(i, j) = 255;
        else
            noise_image(i, j) = image(i, j);
        end
    end
end

noise_image = uint8(noise_image);

end


function box_image = box_filter(image, mf, nf)
[m, n] = size(image);
box_image = zeros(m, n);

for i = 1:m
    for j = 1:n
        buffer = [];
        for fi = -floor(mf / 2) : floor(mf / 2)
            for fj = -floor(nf / 2) : floor(nf / 2)
                if isBound(i+fi, j+fj, m, n)
                    buffer(end+1) = image(i+fi, j+fj);
                end
            end
        end
        buffer = sort(buffer);
        len = length(buffer);
        sum = array_sum(buffer);
        box_image(i, j) = floor(sum / len);
    end
end

box_image = uint8(box_image);

end


function value = array_sum(array)
value = 0;
for i = 1:length(array)
    value = value + array(i);
end
end


function median_image = median_filter(image, mf, nf)
[m, n] = size(image);
median_image = zeros(m, n);

for i = 1:m
    for j = 1:n
        buffer = [];
        for fi = -floor(mf / 2) : floor(mf / 2)
            for fj = -floor(nf / 2) : floor(nf / 2)
                if isBound(i+fi, j+fj, m, n)
                    buffer(end+1) = image(i+fi, j+fj);
                end
            end
        end
        median_image(i, j) = compute_median(buffer);
    end
end

median_image = uint8(median_image);

end


function median_val = compute_median(array)
array = sort(array);
n = length(array);

if mod(n, 2)==1
    median_val = array(floor(n / 2) + 1);
else
    median_val = (array(n / 2) + array(n / 2 + 1)) / 2;
end

end


function is_bound = isBound(i, j, m, n)
is_bound = (1 <= i) && (i <= m) && (1 <= j) && (j <= n);
end


function snr = SNR(image, noise_image)
image = double(image) / 255;
noise_image = double(noise_image) / 255;
image_var = compute_image_var(image);
noise_image_var = compute_image_vs(image, noise_image);
snr = 20 * log10(sqrt(image_var / noise_image_var));
end


function image_mean = compute_image_diff_mean(image, noise_image)
[m, n] = size(image);
N = m * n;
image_mean = 0;

for i = 1:m
    for j = 1:n
        image_mean = image_mean + noise_image(i, j) - image(i, j);
    end
end
image_mean = image_mean / N;

end


function image_var = compute_image_vs(image, noise_image)
[m, n] = size(image);
N = m * n;
noise_image_mean = compute_image_diff_mean(image, noise_image);
image_var = 0;

for i = 1:m
    for j = 1:n
        image_var = image_var + (noise_image(i, j) - noise_image_mean - image(i, j))^2;
    end
end
image_var = image_var / N;

end


function image_var = compute_image_var(image)
[m, n] = size(image);
tmp_image = zeros(m, n);
image_var = compute_image_vs(tmp_image, image);

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

end


function opening_image = opening(img, kernel)
img = double(img);
opening_image = erosion(img, kernel);
opening_image = dilation(opening_image, kernel);

end


function closing_image = closing(img, kernel)
img = double(img);
closing_image = dilation(img, kernel);
closing_image = erosion(closing_image, kernel);

end


function opening_then_closing_image = opening_then_closing(img, kernel)
opening_then_closing_image = opening(img, kernel);
opening_then_closing_image = closing(opening_then_closing_image, kernel);
opening_then_closing_image = uint8(opening_then_closing_image);
end


function closing_then_opening_image = closing_then_opening(img, kernel)
closing_then_opening_image = closing(img, kernel);
closing_then_opening_image = opening(closing_then_opening_image, kernel);
closing_then_opening_image = uint8(closing_then_opening_image);
end


%%
function generate_noise_image_and_denoising_image(image, noise_image, noise_name)

kernel = [0 1 1 1 0;
          1 1 1 1 1;
          1 1 1 1 1;
          1 1 1 1 1;
          0 1 1 1 0];

figure()

subplot(4, 2, 1)
imshow(image, 'InitialMagnification', 'fit');
title('original image');

subplot(4, 2, 2)
imshow(noise_image, 'InitialMagnification', 'fit');
noise_snr = SNR(image, noise_image);
title([noise_name, ' SNR:', num2str(noise_snr)]);

% (c) Use the 3x3, 5x5 box filter on images generated by (a)(b)
subplot(4, 2, 3)
box_3x3_image = box_filter(noise_image, 3, 3);
box_3x3_snr = SNR(image, box_3x3_image);
imshow(box_3x3_image, 'InitialMagnification', 'fit');
title(['Box 3x3 SNR:', num2str(box_3x3_snr)]);

subplot(4, 2, 4)
box_5x5_image = box_filter(noise_image, 5, 5);
box_5x5_snr = SNR(image, box_5x5_image);
imshow(box_5x5_image, 'InitialMagnification', 'fit');
title(['Box 5x5 SNR:', num2str(box_5x5_snr)]);

% (d) Use 3x3, 5x5 median filter on images generated by (a)(b)
subplot(4, 2, 5)
median_3x3_image = median_filter(noise_image, 3, 3);
median_3x3_snr = SNR(image, median_3x3_image);
imshow(median_3x3_image, 'InitialMagnification', 'fit');
title(['Median 3x3 SNR:', num2str(median_3x3_snr)]);

subplot(4, 2, 6)
median_5x5_image = median_filter(noise_image, 5, 5);
median_5x5_snr = SNR(image, median_5x5_image);
imshow(median_5x5_image, 'InitialMagnification', 'fit');
title(['Median 5x5 SNR:', num2str(median_5x5_snr)]);

% (e) Use both opening-then-closing and closing-then opening filter
% (using the octogonal 3-5-5-5-3 kernel, value = 0) on images generated by (a)(b)
subplot(4, 2, 7)
opening_then_closing_image = opening_then_closing(noise_image, kernel);
opening_then_closing_snr = SNR(image, opening_then_closing_image);
imshow(opening_then_closing_image, 'InitialMagnification', 'fit');
title(['Opening and closing SNR:', num2str(opening_then_closing_snr)]);

subplot(4, 2, 8)
closing_then_opening_image = closing_then_opening(noise_image, kernel);
closing_then_opening_snr = SNR(image, closing_then_opening_image);
imshow(closing_then_opening_image, 'InitialMagnification', 'fit');
title(['Closing then opening SNR:', num2str(closing_then_opening_snr)]);

end
