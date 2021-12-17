clear;clc
A = rand(5,2);
[Q, R, H] = HouseHolder(A);
disp('Mine:')
norm(A-Q*R)
[Q, R] = qr(A);
disp('Matlab:')
norm(A-Q*R)