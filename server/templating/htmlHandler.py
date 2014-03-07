from os.path import join
from os.path import dirname
from google.appengine.api import users
from server.db.appDB import User
import jinja2
import webapp2


template_dir = join(dirname(dirname(dirname(__file__))),"assets/html")
jinja_env = jinja2.Environment(autoescape=True,
    loader=jinja2.FileSystemLoader(join(dirname(dirname(dirname(__file__))),"assets/html")))

class Handle(webapp2.RequestHandler):
	def write(self, *a, **kw):
		self.response.out.write(*a, **kw)
	def render_str(self, template, **params):
		t = jinja_env.get_template(template)
		return t.render(params)
	def render(self, template, **kw):
		self.write(self.render_str(template, **kw))

class HandleUserCentric(Handle):
	def get(self):
		openid_user = users.get_current_user()
		user        = User.get_by_uid_lazy(user_id = openid_user.user_id())
		return self.getWithUser(user)
	def post(self):
		openid_user = users.get_current_user()
		user        = User.get_by_uid_lazy(user_id = openid_user.user_id())
		return self.postWithUser(user)
		