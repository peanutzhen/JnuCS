clear;clc
run init.m

% QR分解 基于豪斯活儿霍尔德反射
[Q_a, R_a, H_a] = HouseHolder(A1);
[Q_b, R_b, H_b] = HouseHolder(A2);

% QR分解误差
disp(['不一致方程组(a)(A-Q*R)的误差:', num2str(norm(A1-Q_a*R_a))])
disp(['不一致方程组(b)(A-Q*R)的误差:', num2str(norm(A2-Q_b*R_b))])
