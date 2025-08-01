% 图像转点云处理程序
clear; clc; close all;

% 参数配置
imagePath = 'demo.jpg';  % 图像路径

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

% 将图像转换为双精度进行点云生成
imgDouble = im2double(originalImg);

% 创建点云数据
[height, width] = size(originalImg);
[xGrid, yGrid] = meshgrid(1:width, 1:height);
pointData = [yGrid(:), xGrid(:), imgDouble(:) * 255];

% 创建点云对象
ptCloud = pointCloud(single(pointData));

% 创建图形界面
figure('Name', '图像转点云处理结果', 'Position', [100, 100, 800, 400]);

% 显示原始灰度图像
subplot(1, 2, 1);
imshow(originalImg);
title('原始灰度图像');

% 显示点云（使用原始图像值）
subplot(1, 2, 2);
pcshow(ptCloud, 'MarkerSize', 5);
title('点云显示');
xlabel('Y轴'); ylabel('X轴'); zlabel('灰度值');
axis equal;
grid on;    