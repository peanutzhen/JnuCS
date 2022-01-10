%% 数值分析第二次实验 插值
% 作者：天才少年甄洛生
% 抄袭狗必死!!

%% 龙格现象素材生成脚本
clear,clc;
sam_x1 = linspace(-1,1,11);
sam_y1 = 1 ./ (1 + 25 * sam_x1.^2);

sam_x2 = linspace(-1,1,21);
sam_y2 = 1 ./ (1 + 25 * sam_x2.^2);

poly_f11 = ndd(sam_x1,sam_y1);
poly_f22 = ndd(sam_x2,sam_y2);

x = [-1:0.01:1];
y1 = 1 ./ (1 + 25 * x.^2);
y2 = poly_f11(x);
y3 = poly_f22(x);

% 开始画图 origin with n = 11
figure(1)
plot(x, y1, 'k-', 'linewidth', 1.1)
hold on
grid on
plot(x, y2, 'r--', 'linewidth', 1.1)
plot(sam_x1, sam_y1, 'o', 'markerfacecolor', [36, 169, 225]/255)

% 坐标轴边框线宽1.1, 坐标轴字体与大小为Times New Roman和16
set(gca, 'linewidth', 1.1, 'fontsize', 16, 'fontname', 'times')
xlabel('X')
ylabel('Y')
% legend还可以使用Location参数设置图标位置
legend('origin', 'n = 11')
title('n = 11 compared with origin')
hold off

% 开始画图 origin with n = 22
figure(2)
plot(x, y1, 'k-', 'linewidth', 1.1)
hold on
grid on
plot(x, y3, 'b-', 'linewidth', 1.1)
plot(sam_x2, sam_y2, 'o', 'markerfacecolor', [29, 191, 151]/255)

% 坐标轴边框线宽1.1, 坐标轴字体与大小为Times New Roman和16
set(gca, 'linewidth', 1.1, 'fontsize', 16, 'fontname', 'times')
xlabel('X')
ylabel('Y')
% legend还可以使用Location参数设置图标位置
legend('origin', 'n = 22')
title('n = 22 compared with origin')
hold off
