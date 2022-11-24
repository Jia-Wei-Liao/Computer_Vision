clc; clear; close all;

image = imread('figure/lena.bmp');

%% (a) Robert's Operator: 12
robert_image = robert(image, 12);
imwrite(robert_image, 'figure/robert.png');

%% (b) Prewitt's Edge Detector: 24
prewitt_image = prewitt(image, 24);
imwrite(prewitt_image, 'figure/prewitt.png')

%% (c) Sobel's Edge Detector: 38
sobel_image = sobel(image, 38);
imwrite(sobel_image, 'figure/sobel.png')

%% (d) Frei and Chen's Gradient Operator: 30
frei_and_chen_image = frei_and_chen(image, 30);
imwrite(frei_and_chen_image, 'figure/frei_and_chen.png')

%% (e) Kirsch's Compass Operator: 135
kirsch_image = kirsch(image, 135);
imwrite(kirsch_image, 'figure/kirsch.png')

%% (f) Robinson's Compass Operator: 43
robinson_image = robinson(image, 43);
imwrite(robinson_image, 'figure/robinson.png')

%% (g) Nevatia-Babu 5x5 Operator: 12500
nevatia_babu_image = nevatia_babu(image, 12500);
imwrite(nevatia_babu_image, 'figure/nevatia_babu.png');


%% function
function out_image = robert(image, threshold)
[m, n] = size(image);
out_m = m - 2;
out_n = n - 2;
image = double(image);
out_image = zeros(out_m, out_n);

for i = 1:out_m
    for j = 1:out_n
        r1 = image(i+1, j+1) - image(i, j);
        r2 = image(i+1, j) - image(i, j+1);

        if sqrt(r1^2 + r2^2) >= threshold
            out_image(i, j) = 0;
        else
            out_image(i, j) = 255;
        end
    end
end

out_image = uint8(out_image);

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


function value = convolution(image, kernel)
[m, n] = size(kernel);
value = 0;

for i = 1:m
    for j = 1:n
        value = value + image(i, j) * kernel(i, j);
    end
end
end


function value = square_addition_root(array)
value = 0;
[m, n] = size(array);

for i = 1:m
    for j = 1:n
        value = value + array(i, j)^2;
    end
end

value = sqrt(value);

end


function out_image = detect_edge(image, kernel_cell, condiction)
[km, kn] = size(kernel_cell{1});
[m, n] = size(image);
out_m = m - (km - 1);
out_n = n - (kn - 1);
image = double(image);
out_image = zeros(out_m, out_n);
kernel_num = length(kernel_cell);
values = zeros(kernel_num, 1);

for i = 1:out_m
    for j = 1:out_n
        local_image = get_local_image(image, kernel_cell{1}, i, j);

        for k = 1:kernel_num
            values(k, 1) = convolution(local_image, kernel_cell{k});

        end
        
        if condiction(values)
            out_image(i, j) = 0;
        else
            out_image(i, j) = 255;
        end
    end
end

out_image = uint8(out_image);

end


function out_image = prewitt(image, threshold)
kernels{1} = [-1 -1 -1;  0 0 0;  1 1 1];
kernels{2} = [-1  0  1; -1 0 1; -1 0 1];
condiction =@(x) square_addition_root(x) >= threshold;
out_image = detect_edge(image, kernels, condiction);

end


function out_image = sobel(image, threshold)
kernels{1} = [-1 -2 -1;  0 0 0;  1 2 1];
kernels{2} = [-1  0  1; -2 0 2; -1 0 1];
condiction =@(x) square_addition_root(x) >= threshold;
out_image = detect_edge(image, kernels, condiction);

end


function out_image = frei_and_chen(image, threshold)
kernels{1} = [-1 -sqrt(2) -1;        0  0       0;  1 sqrt(2) 1];
kernels{2} = [-1        0  1;  -sqrt(2) 0 sqrt(2); -1       0 1];
condiction =@(x) square_addition_root(x) >= threshold;
out_image = detect_edge(image, kernels, condiction);

end


function out_image = kirsch(image, threshold)
kernels{1} = [-3 -3  5; -3  0  5; -3 -3  5];
kernels{2} = [-3  5  5; -3  0  5; -3 -3 -3];
kernels{3} = [ 5  5  5; -3  0 -3; -3 -3 -3];
kernels{4} = [ 5  5 -3;  5  0 -3; -3 -3 -3];
kernels{5} = [ 5 -3 -3;  5  0 -3;  5 -3 -3];
kernels{6} = [-3 -3 -3;  5  0 -3;  5  5 -3];
kernels{7} = [-3 -3 -3; -3  0 -3;  5  5  5];
kernels{8} = [-3 -3 -3; -3  0  5; -3  5  5];
condiction =@(x) max(x) >= threshold;
out_image = detect_edge(image, kernels, condiction);

end


function out_image = robinson(image, threshold)
kernels{1} = [-1  0  1; -2  0  2; -1  0  1];
kernels{2} = [ 0  1  2; -1  0  1; -2 -1  0];
kernels{3} = [ 1  2  1;  0  0  0; -1 -2 -1];
kernels{4} = [ 2  1  0;  1  0 -1;  0 -1 -2];
kernels{5} = [ 1  0 -1;  2  0 -2;  1  0 -1];
kernels{6} = [ 0 -1 -2;  1  0 -1;  2  1  0];
kernels{7} = [-1 -2 -1;  0  0  0;  1  2  1];
kernels{8} = [-2 -1  0; -1  0  1;  0  1  2];
condiction =@(x) max(x) >= threshold;
out_image = detect_edge(image, kernels, condiction);

end

function out_image = nevatia_babu(image, threshold)
kernels{1} = [ 100  100  100  100  100;
               100  100  100  100  100;
                 0    0    0    0    0;
              -100 -100 -100 -100 -100;
              -100 -100 -100 -100 -100];

kernels{2} = [ 100  100  100  100  100;
               100  100  100   78  -32;
               100   92    0  -92 -100;
                32  -78 -100 -100 -100;
              -100 -100 -100 -100 -100];

kernels{3} = [ 100  100  100   32 -100;
               100  100   92  -78 -100;
               100  100    0 -100 -100;
               100   78  -92 -100 -100;
               100  -32 -100 -100 -100];
              
kernels{4} = [-100 -100    0  100  100;
              -100 -100    0  100  100;
              -100 -100    0  100  100;
              -100 -100    0  100  100;
              -100 -100    0  100  100];

kernels{5} = [-100   32  100  100  100;
              -100  -78   92  100  100;
              -100 -100    0  100  100;
              -100 -100  -92   78  100;
              -100 -100 -100  -32  100];

kernels{6} = [ 100  100  100  100  100;
               -32   78  100  100  100;
              -100  -92    0   92  100;
              -100 -100 -100  -78   32;
              -100 -100 -100 -100 -100];

condiction =@(x) max(x) >= threshold;
out_image = detect_edge(image, kernels, condiction);

end


