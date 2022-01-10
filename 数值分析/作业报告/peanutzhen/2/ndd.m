%% 数值分析第二次实验 插值
% 作者：天才少年甄洛生
% 抄袭狗必死!!

function f = ndd(sam_x,sam_y)
% ndd - Description
% ndd 为 Newton's divided difference的缩写。
% 顾名思义，生成牛顿差商插值多项式
% x：样本点x
% y：样本点y
% f：插值多项式
% Syntax: f = ndd(x,y)
    n = length(sam_x);          % 获取样本点数
    table = zeros(n,n);
    table(:,1) = sam_y;         % 初始化差商表

    % 计算差商表
    for gap = [1: n-1]
        for count = [1: n-gap]
            table(count, gap+1) = (table(count+1,gap) - table(count,gap))/(sam_x(count+gap) - sam_x(count));
        end
    end
    % 形成系数表
    c = table(1,:);
    % 形成(x-x_i) x_matrix
    syms x
    x_mat = sym(ones(n,1));
    for iter1 = [2:n]
        x_mat(iter1:n,1) = x_mat(iter1:n,1) * (x - sam_x(iter1-1));
    end
    % 构成牛顿差商插值多项式
    f(x) = c * x_mat;
    % 化简，返回
    f = simplify(f);
end