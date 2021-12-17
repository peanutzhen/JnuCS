from Crawler import Crawler, getUrlTitle
from PowerIteration import power_iteration
from FigGen import gen_result_fig, gen_sparse_fig
from os.path import exists
from json import dump, load
from datetime import datetime
import numpy as np

if not exists('data.json'):
    crawler = Crawler(
        baseURL='https://www.jnu.edu.cn',
        verbose=True # False则不显示debug信息
    )

    start = datetime.now()
    crawler.run()
    end = datetime.now()
    gap = end - start
    print('网站爬取用时:', gap.total_seconds(), '秒')

    data = dict()
    data['adjacent_matrix'] = crawler.getAdjacentMatrix()
    data['directed_graph'] = crawler.link_graph
    data['num_site'] = crawler.num_site

    with open('data.json', 'w', encoding='utf-8') as f:
        dump(data, f, ensure_ascii=False, indent=4)

with open('data.json', 'r') as f:
    data = load(f)

M = data.get('adjacent_matrix')
G = data.get('directed_graph')
num_site = data.get('num_site')
alpha = 0.15

gen_sparse_fig(M, filename='Assets/adjacent_matrix.png')   # 绘制稀疏矩阵

# 相邻矩阵M to Google矩阵M
for row in range(num_site):
    row_sum = sum(M[row])
    if row_sum == 0:
        for col in range(num_site):
            M[row][col] = 1 / num_site
    else:
        for col in range(num_site):
            random_surf = alpha * (1 / num_site)
            outlink_surf = (1 - alpha) * (M[row][col] / row_sum)
            M[row][col] = random_surf + outlink_surf


# 幂迭代
result = power_iteration(np.array(M).transpose())
gen_result_fig(result, 'Assets/result.png')
result = [(key, result[i]) for i, key in enumerate(G.keys())]

# Rank
page_rank = sorted(result, key=lambda x:x[1], reverse=True)

# 显示前20
for i in range(20):
    msg = 'TOP %d "%s"\nURL    %s\nRankValue %f' % (i+1, getUrlTitle(page_rank[i][0]), page_rank[i][0], page_rank[i][1])
    print(msg)

# 保存PageRank
with open('page_rank.json', 'w') as f:
    dump(page_rank, f)

