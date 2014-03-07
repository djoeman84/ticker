import webapp2, json, re
from google.appengine.api import users
from server.db.appDB import User, Player, Game, Score

class Handle(webapp2.RequestHandler):
	def publish(self, obj):
		self.response.headers['Content-Type'] = 'application/json'
		self.response.out.write(json.dumps(obj))
	def formatToJSONKey(self, obj):
		return obj.key().id()
	def formatForJSON(self, obj):
		if isinstance(obj,User):
			return {
				'not':'implemented'
			}
		if isinstance(obj,Game):
			return {
				'id':self.formatToJSONKey(obj),
				'name':obj.name,
				'created':obj.created.isoformat(),
				'user_id':self.formatToJSONKey(obj.user)
			}
		return None

class HandleUserCentric(Handle):
	def get(self, *args, **kwargs):
		openid_user = users.get_current_user()
		user        = User.get_by_uid_lazy(user_id = openid_user.user_id())
		return self.getWithUser(user, *args, **kwargs)
	def post(self, *args, **kwargs):
		openid_user = users.get_current_user()
		user        = User.get_by_uid_lazy(user_id = openid_user.user_id())
		return self.postWithUser(user, *args, **kwargs)