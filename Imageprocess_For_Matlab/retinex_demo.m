% 基于Retinex算法的图像转点云处理程序
clear; clc; close all;

% 参数配置
imagePath = 'demo.jpg';  % 图像路径
sigma = 20;                % Retinex高斯滤波标准差

% 读取图像并转换为灰度图
try
    originalImg = imread(imagePath);
    if ndims(originalImg) == 3
        originalImg = rgb2gray(originalImg);
    end
catch ME
    fprintf('无法读取图像: %s\n', ME.message);
    return;
end

% 应用Retinex算法增强图像
enhancedImg = retinex_algorithm(originalImg, sigma);

% 创建点云数据
[height, width] = size(enhancedImg);
[xGrid, yGrid] = meshgrid(1:width, 1:height);
pointData = [yGrid(:), xGrid(:), enhancedImg(:) * 255];

% 创建点云对象
ptCloud = pointCloud(single(pointData));

% 创建图形界面
figure('Name', '基于Retinex的图像转点云处理结果', 'Position', [100, 100, 1200, 400]);

% 显示原始灰度图像
subplot(1, 3, 1);
imshow(originalImg);
title('原始灰度图像');

% 显示Retinex增强后的图像
subplot(1, 3, 2);
imshow(enhancedImg);
title('Retinex增强后的图像');

% 显示点云
subplot(1, 3, 3);
pcshow(ptCloud, 'MarkerSize', 5);
title('点云显示');
xlabel('Y轴'); ylabel('X轴'); zlabel('灰度值');
axis equal;
grid on;

function enhancedImg = retinex_algorithm(img, sigma)
    % 输入: 图像img和空间标准差sigma
    % 输出: 增强后的图像
 
    % 将图像转换为对数形式
    img_log = log(double(img) + 1);
    
    % 计算平滑后的图像
    img_smoothed = imgaussfilt(img_log, sigma);
    
    % 计算增强图像
    enhanced_img = img_log - img_smoothed;
    
    % 将结果转换回正常的强度范围
    enhancedImg = exp(enhanced_img);
end    