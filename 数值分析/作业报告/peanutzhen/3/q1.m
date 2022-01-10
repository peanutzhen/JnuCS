clear;clc
% 导入数据
run init.m

% QR分解
[Q_a, R_a] = ClassicalGS(A1);
[Q_b, R_b] = ClassicalGS(A2);

% QR分解误差
disp(['不一致方程组(a)(A-Q*R)的误差:', num2str(norm(A1-Q_a*R_a))])
disp(['不一致方程组(b)(A-Q*R)的误差:', num2str(norm(A2-Q_b*R_b))])

% 作者甄洛生 抄袭死m
