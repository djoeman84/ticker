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
		self.render('index.html')



class SimpleHandler(htmlHandler.Handle):
	def get(self):
		path = self.request.path
		path = path.replace('/','')
		try:
			self.render(path+'.html')
		except:
			self.render('404.html')


app = webapp2.WSGIApplication([
	('/',                  HomeHandler),
    ('/.*',                SimpleHandler)
], debug=True)
