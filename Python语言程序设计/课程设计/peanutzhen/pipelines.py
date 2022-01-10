from movie_crawler.items import MovieItem
from scrapy.pipelines.images import ImagesPipeline
from scrapy.http import Request
from movie_crawler import settings
from scrapy.exceptions import DropItem
import os

image_store = settings.IMAGES_STORE

class MovieCrawlerPipeline(ImagesPipeline):
	def get_media_requests(self, item, info):
		if isinstance(item,MovieItem):
			item['actors']=item['actors'].replace(' ','')
			item['actors']=item['actors'].replace('\n','')
			yield Request(item['image_url'])
			
	def file_name(self,request, respond, info):
		return request.url.split('/')[-1]

	def item_completed(self, results, item, info):
		paths = [result['path'] for status,result in results if status]
		if not paths:
			raise DropItem('Failed to download photo.')
		else:
			os.rename(image_store+'/'+paths[0],image_store+'/'+item['name']+'.jpg')
		return item
	