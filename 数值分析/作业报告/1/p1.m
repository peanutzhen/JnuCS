clear;clc

%% 定义常量
A = diag(repmat(1/2,999,1),1) + diag(repmat(1/2,998,1),2);
A = A + diag(repmat(1/2,999,1),-1) + diag(repmat(1/2,998,1),-2);
A = diag(1:1000) + A;
b = repmat(1,1000,1);

%% 判断是否为严格对角占优矩阵
if abs(diag(A)) > sum(abs(A-diag(diag(A))),2)
    disp('Aha, here it is.')
else
    disp('Oh shit! Not a strictly diagonally dominant.')
end

LOOP = 15;    % 迭代次数
% 求解析解
real_x = inv(A) * b;

%% Jacobi Method
disp('Jacobi...')
% 分解A为 L D U
D = diag(diag(A));  % 对角矩阵
L = tril(A,-1);      % 下三角矩阵
U = triu(A,1);      % 上三角矩阵
% 设定初始解x向量
old_x = zeros(length(b),1);
% 记录每一次迭代误差值
Error_Jacobi = zeros(1,LOOP);
for count = 1: LOOP
    Jacobi = inv(D) * (b - (L + U) * old_x);
    % calculate error
    Error_Jacobi(count) = ErrorFunc(Jacobi, real_x);
    % update
    old_x = Jacobi;
end
% 显示解
%disp('Jacobi method:')
%disp(new_x')


%% Gauss-seidel Method
disp('Gauss-seidel...')
% 设定初始解x向量
old_x = zeros(length(b),1);
Gauss_seidel = zeros(size(old_x));

% 记录每一次迭代误差值
Error_Gauss_seidel = zeros(1,LOOP);
LU = L + U;
invD = inv(D);
for count = 1: LOOP
    % 依次求每个变量新的值，每次求新的值时，有些变量已经是最新的值
    for index = 1 : length(old_x)
        old_x(index) = invD(index,index) * (b(index) - LU(index, :) * old_x);
        Gauss_seidel = old_x;
    end
    Error_Gauss_seidel(count) = ErrorFunc(Gauss_seidel, real_x);
end
% 显示解
%disp('Gauss-seidel method:')
%disp(new_x')


%% SOR with omega == 1.1
disp('SOR...')
omega = 1.1;
% 设定初始解x向量
old_x = zeros(length(b),1);
invD = inv(D);
LU = L + U;
Error_SOR = zeros(1,LOOP);
for count = 1: LOOP
    for index = 1 : length(old_x)
        old_x(index) = (1 - omega) * old_x(index) + invD(index,index) * omega * (b(index) - (LU(index, :) * old_x));
    end
    SOR = old_x;
    Error_SOR(count) = ErrorFunc(SOR, real_x);
end
% 显示解
%disp('SOR-omega1.1 method:')
%disp(new_x')


%% Conjugate Gradient Method
disp('Conjugate gradient...')
% 设定初始解x向量
x = zeros(length(b),1);
old_d = b;
old_r = b;
zero_r = zeros(size(old_r));
Error_Conjugate = zeros(1,LOOP);
for count = 1: LOOP
    if old_r == zero_r
        break
    else
        alpha = (old_r' * old_r) / (old_d' * A * old_d);
        Conjugate = x + alpha * old_d;  % new x
        new_r = old_r - alpha * A * old_d;
        my_beta = (new_r' * new_r) / (old_r' * old_r);
        new_d = new_r + my_beta * old_d;
        % calculate error
        Error_Conjugate(count) = ErrorFunc(Conjugate, real_x);
        % update d and r
        old_d = new_d;
        old_r = new_r;
        x = Conjugate;
    end
end
% 显示解
%disp('Conjugate Gradient method:')
%disp(x')


%% Conjugate Gradient Method with Jacobi preconditioner
disp('Conjugate gradient with Jacobi...')
M = D;
% 设定初始解x向量
x = zeros(length(b),1);
old_r = b;
old_d = inv(M) * old_r;
old_z = old_d;

zero_r = zeros(size(old_r));

Error_CJ = zeros(1, LOOP);
for count = 1: LOOP
    if old_r == zero_r
        break
    else
        alpha = (old_r' * old_z) / (old_d' * A * old_d);
        Conjugate_Jacobi = x + alpha * old_d;  % new x
        new_r = old_r - alpha * A * old_d;
        new_z = inv(M) * new_r;
        my_beta = (new_r' * new_z) / (old_r' * old_z);
        new_d = new_z + my_beta * old_d;
        % calculate error
        Error_CJ(count) = ErrorFunc(Conjugate_Jacobi, real_x);
        % update d r z x
        old_d = new_d;
        old_r = new_r;
        old_z = new_z;
        x = Conjugate_Jacobi;
    end
end
% 显示解
%disp('Conjugate Gradient method with Jacobi preconditioner:')
%disp(x')


%% 作误差图
figure(1)
% Jacobi
plot(1:LOOP, Error_Jacobi, 'ok-', 'linewidth', 1.1, 'markerfacecolor', [217, 57, 47]/255)
hold on
% Gauss
plot(1:LOOP, Error_Gauss_seidel, 'sk-', 'linewidth', 1.1, 'markerfacecolor', [78, 165, 236]/255)
% SOR
plot(1:LOOP, Error_SOR, '*k-', 'linewidth', 1.1, 'markerfacecolor', [53, 116, 66]/255)
% Conjugate
plot(1:LOOP, Error_Conjugate, 'xk-', 'linewidth', 1.1, 'markerfacecolor', [159, 144, 191]/255)
% Conjugate with Jacobi
plot(1:LOOP, Error_CJ, 'pk-', 'linewidth', 1.1, 'markerfacecolor', [132, 134, 134]/255)
% Figure 属性
set(gca, 'linewidth', 1.1, 'fontsize', 16, 'fontname', 'times')
xlabel('Epochs')
ylabel('Error')
title('Problem 1 Performance')
legend('Jacobi', 'Gauss', 'SOR', 'Conjugate', 'Con & Jacobi')
grid on

%% 保存答案至excel
title = {"解析解","雅可比","高斯赛德","SOR","共轭梯度","共轭梯度with预条件"};
output = [real_x,Jacobi,Gauss_seidel,SOR,Conjugate,Conjugate_Jacobi];
output = [title; num2cell(output)];
