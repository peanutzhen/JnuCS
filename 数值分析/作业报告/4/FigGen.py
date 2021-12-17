import matplotlib.pyplot as plt
import numpy as np

def gen_sparse_fig(M, filename):
    n = len(M)
    plt.spy(M, markersize=1)
    plt.xlim([1,500])
    plt.ylim([500,1])
    # 统计稀疏率
    non_zero_elements = 0
    for i in range(len(M)):
        non_zero_elements = non_zero_elements + sum(M[i])

    title = 'Sparsity: {:.3f}%'.format((non_zero_elements*100)/(n*n))
    plt.title(title)

    plt.savefig(
        filename,
        dpi=400,
        bbox_inches='tight'
    )
    plt.close()

def gen_result_fig(result, filename):
    X = [x for x in range(len(result))]
    Y = result
    plt.scatter(X, Y)
    plt.title('Each page rank value distribution')
    plt.xlabel('Page Number')
    plt.ylabel('Rank Value')
    plt.grid('on')
    plt.savefig(
        filename,
        dpi=400
    )
    plt.close()
