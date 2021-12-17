import numpy as np

alpha = 0.15

def power_iteration(M):
    n = M.shape[0]

    # x0 = [1 0 0 ... 0]
    x = [0 for i in range(n)]
    x[0] = 1
    x = np.array(x)

    # e = [1 1 ... 1]
    e = np.array([1 for i in range(n)])


    # 常规解法
    while True:
        x_new = np.dot(M,x)
        dist = np.linalg.norm(x_new - x)
        if dist < 1e-20:    # 我随便设的阈值
            break
        else:
            x = x_new
    return x_new
