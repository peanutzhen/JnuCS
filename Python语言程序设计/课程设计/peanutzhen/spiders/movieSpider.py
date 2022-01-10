from scrapy.linkextractors import LinkExtractor
from scrapy.spiders import CrawlSpider, Rule
from movie_crawler.items import MovieItem

class TopMovieSpider(CrawlSpider):
	name='8bit_spider'
	allowed_domains=['movie.douban.com']
	start_urls = ['https://movie.douban.com/top250']
	rules = [Rule(LinkExtractor(allow=r'^https://movie\.douban\.com/top250\?start=\d+&filter=$'),
				 callback='parse_items', follow=False)]
	
	def parse_items(self,response):
		order_list = response.xpath('//*[@id="content"]')
		order_list = order_list.xpath('//div[@class="item"]')
		for list_item in order_list:
			movie = MovieItem()
			movie['name'] = list_item.xpath('.//span[@class="title"]/text()').get()
			#actors needs processing later.
			movie['actors'] = list_item.xpath('.//p/text()').get()
			movie['rating'] = list_item.xpath('.//span[@class="rating_num"]/text()').get()
			movie['description'] = list_item.xpath('.//span[@class="inq"]/text()').get()
			movie['image_url'] = list_item.xpath('.//img/@src').get()
			yield movie
			
