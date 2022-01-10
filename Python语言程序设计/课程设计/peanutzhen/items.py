# -*- coding: utf-8 -*-

# Define here the models for your scraped items
#
# See documentation in:
# https://docs.scrapy.org/en/latest/topics/items.html

import scrapy


class MovieItem(scrapy.Item):
    name = scrapy.Field()
    actors = scrapy.Field()
    rating = scrapy.Field()
    description = scrapy.Field()
    image_url = scrapy.Field()
    image = scrapy.Field()
    image_path = scrapy.Field()