from requests import get, head
from bs4 import BeautifulSoup
from random import sample
from urllib.parse import urljoin
from time import sleep

# 设置每个节点至多出边、节点总数
NUM_SITE_LIM = 500
RELATIVE_OUTLINKS_LIM = 20

class Crawler:
    headers = {
        'user-agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/87.0.4280.88 Safari/537.36'
    }
    num_site = 0                # 已爬取网站个数
    crawling = []               # 待爬池
    checked = set()             # 已爬池
    unreachable_site = set()    # 坏节点池
    link_graph = {}             # 网站连接图

    def __init__(self, baseURL, verbose):
        # verbose 为 True 时，打印debug信息
        self.crawling.append(baseURL)
        self.num_site = self.num_site + 1
        self.verbose = verbose

    def extractOutLink(self, url):
        try:
            response = head(url)
            if 'text/html' not in response.headers['content-type']:
                raise Exception
            response = get(url, headers=self.headers, timeout=10)
        except:
            # 网站在指定时间到不了，或者url不是返回html
            self.checked.remove(url)
            self.unreachable_site.add(url)
            self.num_site = self.num_site - 1
            return False
        
        # 设置为utf-8，否则中文乱码
        response.encoding = 'utf-8'
        soup = BeautifulSoup(response.text, 'lxml')

        # 这里保证outlinks是绝对url
        # 并且限制相对url的数目（避免太多非首页的url）
        # 并且只爬https
        outlinks = soup.find_all('a', href=True)
        relative_urls = [url['href'] for url in outlinks if url['href'].startswith('/')]
        absolute_urls = [url['href'] for url in outlinks if url['href'].startswith('https')]
        relative_urls = sample(relative_urls, min(len(relative_urls), RELATIVE_OUTLINKS_LIM))
        absolute_urls = absolute_urls + [urljoin(url, outlink) for outlink in relative_urls]
        outlinks = absolute_urls
        # 去除link后无效的'/'
        outlinks = [outlink[:-1] if outlink.endswith('/') else outlink for outlink in outlinks ]

        for outlink in outlinks:
            if outlink not in self.crawling and \
               outlink not in self.checked  and \
               outlink not in self.unreachable_site and \
               self.num_site < NUM_SITE_LIM:
                self.crawling.append(outlink)
                self.num_site = self.num_site + 1
        
        self.link_graph[url] = outlinks
        response.close()
        return True

    def run(self):
        #print('要是我ip被封了你妈买菜必涨价')
        index = 1
        while self.crawling:
            url = self.crawling.pop(0)
            self.checked.add(url)
            status = self.extractOutLink(url)
            if self.verbose:
                print('Page', index,':', url, '->', status)
                index = index + 1
        if self.verbose:
            print('Hah, we make it! Total numbers of site:', self.num_site)
            print('keys:', len(self.link_graph.keys()))

    def getAdjacentMatrix(self):
        # 从有向图转成相邻矩阵
        keys = tuple(self.link_graph.keys())

        for key in keys:
            for site in self.link_graph[key]:
                if site not in keys or site == key:
                    self.link_graph[key] = [x for x in self.link_graph[key] if x != site]

        M = [ [0]*self.num_site for i in range(self.num_site) ]

        for site, outlinks in self.link_graph.items():
            i = keys.index(site)
            for outlink in outlinks:
                j = keys.index(outlink)
                M[i][j] = 1
        
        return M

def getUrlTitle(url):
    # 返回对应 URL 的 <title>
    headers = {
        'user-agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/87.0.4280.88 Safari/537.36'
    }
    response = get(url, headers=headers)
    response.encoding = 'utf-8'
    soup = BeautifulSoup(response.text, 'lxml')
    response.close()
    return soup.find('title').text
