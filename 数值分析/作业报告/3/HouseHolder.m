function [Q, R, H_list] = HouseHolder(A)
    %% 基于豪斯霍尔德反射的QR分解
    % H_list 是每一步反射子矩阵

    m = size(A, 1);
    n = size(A, 2);
    R = A;
    H_list = cell(1, n);
    for k = 1 : n
        x = R(k:end, k);
        w = zeros(size(x));
        w(1) = norm(x);

        v = w - x;
        P = (1 / (v' * v))*(v .* v');
        H_hat = eye(size(P)) - 2 * P;
        H = eye(m);
        H(k:end,k:end) = H_hat;
        R = H * R;  % 等 k = n 时，R才是真正意义上的R
        % 其他时候都是 H_i * H_(i-1) * ... * H_2 * H_1 * A 

        H_list{k} = H;
    end
    % 计算 Q
    Q = H_list{1};
    for k = 2 : n
        Q = Q * H_list{k};
    end
end