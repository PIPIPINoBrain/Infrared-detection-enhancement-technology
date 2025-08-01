% 图像转点云处理程序
clear; clc; close all;

% 参数配置
imagePath = "demo.jpg";  % 图像路径
windowSize = 10;           % 直方图扩展窗口大小

% 读取图像并转换为灰度图
try
    img = imread(imagePath);
catch ME
    fprintf('无法读取图像: %s\n', ME.message);
    return;
end

% 确保图像为灰度图
if ndims(img) == 3
    gray = rgb2gray(img);
else
    gray = img;
end

% 获取图像尺寸
[height, width] = size(gray);

% 扩展直方图计算（向两侧扩展windowSize个像素）
histExtended = zeros(1, 256);
validRange = windowSize+1 : 255-windowSize; % 有效像素范围

% 将图像数据转换为从1开始的索引
grayIndices = gray + 1; % 将0-255范围转换为1-256

% 使用向量化操作替代嵌套循环，提高性能
for k = -windowSize:windowSize
    shiftedIndices = grayIndices + k;
    shiftedIndices = max(1, min(256, shiftedIndices)); % 确保索引在1-256范围内
    histExtended = histExtended + accumarray(shiftedIndices(:), 1, [256, 1])';
end

% 归一化处理
normalizedHist = round(histExtended / (height * width) * 255);

% 生成新的灰度图像（反转处理）
grayNew = 1 - normalizedHist(gray + 1) / 255;

% 转换为uint8类型
grayNewUint8 = im2uint8(grayNew);

% 创建点云数据
[xGrid, yGrid] = meshgrid(1:width, 1:height);
pointData = [yGrid(:), xGrid(:), grayNew(:) * 255];

% 创建点云对象并显示
ptCloud = pointCloud(single(pointData));

% 创建图形界面
figure('Name', '图像转点云处理结果', 'Position', [100, 100, 1200, 400]);

% 显示原始灰度图像
subplot(1, 3, 1);
imshow(gray);
title('原始灰度图像');

% 显示处理后的图像
subplot(1, 3, 2);
imshow(grayNewUint8);
title('处理后的图像');

% 显示点云
subplot(1, 3, 3);
pcshow(ptCloud, 'MarkerSize', 5);
title('点云显示');
xlabel('Y轴'); ylabel('X轴'); zlabel('灰度值');
axis equal;
grid on;    