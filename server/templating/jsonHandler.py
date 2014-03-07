import webapp2
import json

class Handle(webapp2.RequestHandler):
	def publish(self, obj):
		self.response.headers['Content-Type'] = 'application/json'
		self.response.out.write(json.dumps(obj))
