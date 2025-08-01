import cv2
import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D

# 参数配置
image_path = "demo.jpg"  # 图像路径
window_size = 10         # 直方图扩展窗口大小

# 读取图像并转换为灰度图
try:
    img = cv2.imread(image_path)
    if img is None:
        raise Exception("无法读取图像文件")
except Exception as e:
    print(f'无法读取图像: {str(e)}')
    exit()

# 确保图像为灰度图
if len(img.shape) == 3:
    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
else:
    gray = img

# 获取图像尺寸
height, width = gray.shape

# 扩展直方图计算（向两侧扩展window_size个像素）
hist_extended = np.zeros(256, dtype=np.float64)
gray_indices = gray + 1  # 将0-255范围转换为1-256

# 使用向量化操作替代嵌套循环，提高性能
for k in range(-window_size, window_size + 1):
    shifted_indices = gray_indices + k
    shifted_indices = np.clip(shifted_indices, 1, 256)  # 确保索引在1-256范围内
    # 计算直方图并累加到扩展直方图
    hist, _ = np.histogram(shifted_indices.flatten(), bins=np.arange(1, 258))
    hist_extended += hist

# 归一化处理
normalized_hist = np.round(hist_extended / (height * width) * 255).astype(np.uint8)

# 生成新的灰度图像（反转处理）
gray_new = 1 - normalized_hist[gray] / 255.0

# 转换为uint8类型
gray_new_uint8 = cv2.normalize(gray_new, None, 0, 255, cv2.NORM_MINMAX, dtype=cv2.CV_8U)

# 创建点云数据
x_grid, y_grid = np.meshgrid(range(width), range(height))
point_data = np.column_stack((y_grid.flatten(), x_grid.flatten(), gray_new.flatten() * 255))

# 创建图形界面
fig = plt.figure(figsize=(15, 5))
fig.canvas.manager.set_window_title('图像转点云处理结果')

# 显示原始灰度图像
ax1 = fig.add_subplot(131)
ax1.imshow(gray, cmap='gray')
ax1.set_title('原始灰度图像')
ax1.axis('off')

# 显示处理后的图像
ax2 = fig.add_subplot(132)
ax2.imshow(gray_new_uint8, cmap='gray')
ax2.set_title('处理后的图像')
ax2.axis('off')

# 显示点云
ax3 = fig.add_subplot(133, projection='3d')
sc = ax3.scatter(point_data[:, 0], point_data[:, 1], point_data[:, 2], 
                 c=point_data[:, 2], cmap='gray', s=1)
ax3.set_title('点云显示')
ax3.set_xlabel('Y轴')
ax3.set_ylabel('X轴')
ax3.set_zlabel('灰度值')
ax3.axis('equal')

plt.tight_layout()
plt.show()
