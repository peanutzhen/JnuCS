function [Q, R] = ClassicalGS(A)
    %% 基于经典格拉姆施密特正交的QR分解

    % 我们已经假设A是n列线性无关的m维向量
    % 由于A可能是 n ≤ m 的，其中n是A的列数，m是行数
    % 我们需要扩展一下A，才能生成m个正交基底
    % 毕竟n个向量至多张成n维空间

    
    % 获取A的行数列数
    m = size(A, 1);
    n = size(A, 2);
    % 初始化返回值
    Q = zeros(m, m);
    R = zeros(m, n);
    % 检查A是否为n个线性无关的向量组
    if rank(A) < n
        disp('A 不是由 n 个线性无关的向量组成的矩阵');
        Q = 0;
        R = 0;
        return ;
    end
    % 若 n < m 我们要填充向量使得 A 的 rank 为 m
    if n < m
        % 保证 rank 为 m 因为只是很大概率 并不是说一定
        while rank(A) ~= m
            for k = 1 : m - n
                % 由于 A 里已经是 n 个线性无关向量的组合
                % 我们可以依次取前m - n个向量，并进行随机变换
                % 这样我们可以很大概率不会与之前的向量有线性相关关系
                A(:, n+k) = rand(m, 1) .* A(:, k);
            end
        end
    end
    % 现在进行经典的嘎拉姆施密特正交分解
    for k = 1 : m
        y = A(:, k);
        for count = 1 : k-1
            if count > n
                break
            end
            R(count, k) = Q(:, count)' * A(:, k);
            y = y - R(count, k) * Q(:, count);
        end
        R(k, k) = norm(y);
        Q(:, k) = y / R(k, k);
    end
    % 只保留 R 的 m*n 的部分
    R = R(1:m, 1:n);
end