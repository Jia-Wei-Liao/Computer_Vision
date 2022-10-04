clc; clear; close all;

img = imread('figure/lena.bmp');
[m, n] = size(img);

%% (a) original image and its histogram
img_hist = computeHist(img);

%%
PlotImg(img, 'figure/image.png');
PlotHist(img_hist, 'figure/image_histogram.png');


%% (b) image with intensity divided by 3 and its histogram
img_divided_by_3 = zeros(m, n);
for i = 1:m
    for j = 1:n
        img_divided_by_3(i, j) = round(img(i, j) / 3);
    end
end

img_divided_by_3 = uint8(img_divided_by_3);
img_divided_by_3_hist = computeHist(img_divided_by_3);

%%
PlotImg(img_divided_by_3, 'figure/image_divided_by_3.png');
PlotHist(img_divided_by_3_hist, 'figure/image_divided_by_3_histogram.png');


%% (c) image after applying histogram equalization to (b) and its histogram
img_normal = computeMinMaxNormalize(double(img_divided_by_3));
img_pdf = computePDF(img_normal);
img_cdf = computeCDF(img_pdf);
he_img = zeros(m, n);

for i = 1:m
    for j = 1:n
        if img_normal(i, j) > 0
            he_img(i, j) = round(img_cdf(img_normal(i, j)) * 255);
        end
    end
end

he_img = uint8(he_img);
he_img_hist = computeHist(he_img);

%%
PlotImg(he_img, 'figure/HE_image.png');
PlotHist(he_img_hist, 'figure/HE_histogram.png');


%% function
function img_hist = computeHist(img)
[m, n] = size(img);
img_hist = zeros(1, 256);
    for g = 0:255
        for i = 1:m
            for j = 1:n
                if img(i, j) == g
                    img_hist(1, g+1) = img_hist(1, g+1) + 1;
                end
            end
        end
    end
end


function img_normal = computeMinMaxNormalize(img)
[m, n] = size(img);
img_min = findNoneZeroMin(img);
img_max = max(img, [], 'all');
img_normal = zeros(m, n);

for i = 1:m
    for j = 1:n
        img_normal(i, j) = round((img(i, j) - img_min) / (img_max - img_min) * 255);
    end
end

end


function img_pdf = computePDF(img)
img_pdf = zeros(1, 256);
img_hist = computeHist(img);
total_num = 0;

for g = 0:255
    total_num = total_num + img_hist(1, g+1);
end

for g = 0:255
    img_pdf(1, g+1) = img_hist(1, g+1) / total_num;
end

end


function img_cdf = computeCDF(img_hist)
img_cdf = zeros(1, 256);
img_cdf(1, 1) = img_hist(1, 1);

for g = 1:255
    img_cdf(1, g+1) = img_cdf(1, g) + img_hist(1, g+1);
end

end


function img_min = findNoneZeroMin(img)
[m, n] = size(img);
img_min = inf;

for i = 1:m
    for j = 1:n
        if (img(i, j) > 0) && (img(i, j) < img_min)
            img_min = img(i, j);
        end
    end
end

end


function PlotImg(img, save_name)
figure()
imshow(img);
set(gcf);
saveas(gcf, save_name);

end


function PlotHist(img_hist, save_name)
figure()
bar(0:255, img_hist);
grid on;
set(gcf);
saveas(gcf, save_name);

end
