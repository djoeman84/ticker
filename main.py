#!/usr/bin/env python
#
# Copyright 2007 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
import webapp2
from server.templating import htmlHandler, jsonHandler
from server.db import tickerDB
from google.appengine.ext import db

class HomeHandler(htmlHandler.Handle):
	def get(self):
		self.render('ticker.html')



class SimpleHandler(htmlHandler.Handle):
	def get(self):
		path = self.request.path
		path = path.replace('/','')
		try:
			self.render(path+'.html')
		except:
			self.render('404.html')

class NewStockHandler(htmlHandler.Handle):
	def get(self):
		self.render('newstock.html')
	def post(self):
		name = self.request.get('name')
		ticker_symbol = self.request.get('ticker_symbol')
		riskRating = int(self.request.get('riskRating'))
		description = self.request.get('description')
		previous_close = float(self.request.get('previous_close'))
		ppe = float(self.request.get('ppe'))
		if name and ticker_symbol and riskRating and description and previous_close and ppe:
			s = tickerDB.Stock(name=name,
				ticker_symbol=ticker_symbol,
				riskRating=riskRating,
				description=description,
				previous_close=previous_close,
				ppe=ppe
			)
			s.put()
		self.redirect('/newstock')

class StocksHandler(htmlHandler.Handle):
	def get(self):
		q = tickerDB.Stock.all()
		q.order("name")
		rs = q.run()
		self.render('stocks.html',stocks = rs)

		
class StockSearchHandler(jsonHandler.Handle):
	def get(self):
		query = self.request.get('q')
		q = tickerDB.Stock.all()
		q.order("name")
		rs = q.run()

		# print "here"
		jsonRes = []#OR ticker_symbol IN :1
		for r in rs:
			if r.name.upper().find(query.upper()) == 0 or r.ticker_symbol.upper().find(query.upper()) == 0:
				jsonRes.append({'name':r.name, 'ticker_symbol':r.ticker_symbol, 'riskRating':r.riskRating, 'description':r.description, 'previous_close':r.previous_close, 'ppe':r.ppe})
		self.publish(jsonRes)
		
		
class stockAutoComplete(jsonHandler.Handle):
	def get(self):
		query = self.request.get('term')
		q = tickerDB.Stock.all()
		q.order("name")
		rs = q.run()

		# print "here"
		jsonRes = []
		for r in rs:
			if r.name.upper().find(query.upper()) == 0 or r.ticker_symbol.upper().find(query.upper()) == 0:
				jsonRes.append({'value':r.ticker_symbol,'label':r.name,'name':r.name, 'ticker_symbol':r.ticker_symbol, 'riskRating':r.riskRating, 'description':r.description, 'previous_close':r.previous_close, 'ppe':r.ppe})
		self.publish(jsonRes)


app = webapp2.WSGIApplication([
	('/',                  HomeHandler),
	('/newstock',          NewStockHandler),
	('/stocks',            StocksHandler),
	('/stockSearch',       StockSearchHandler),
	('/stockAutoComplete', stockAutoComplete),
    ('/.*',                SimpleHandler)
], debug=True)
