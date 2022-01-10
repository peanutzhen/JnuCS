%% 数值分析第二次实验 插值
% 作者：天才少年甄洛生
% 抄袭狗必死!!

%% 前情提要：
% 原函数fx为e^(-2x)
% 定义域为[-1,1]
% 样本点数分别为10 20 40
% 使用等距间隔采样和切比雪夫采样进行牛顿差商插值
clear;clc;
syms x
f(x) = exp(-2*x);
%% n = ?
n = input('Enter nums of sample points: ');
equ_x = linspace(-1,1,n);
chebx = cos((2*[1:n]-1)*pi/(2*n));
[equ_f, chebf] = step3(equ_x, chebx, f);
step4(equ_f,chebf,f,['n = ', num2str(n), ' 等距点与切比雪夫点插值误差对比'])