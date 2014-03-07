from google.appengine.ext import db



class Stock(db.Model):
	name              = db.StringProperty(required = True)
	ticker_symbol     = db.StringProperty(required = True)
	riskRating        = db.RatingProperty(required = True)
	description       = db.TextProperty(required = True)
	previous_close    = db.FloatProperty(required = True)
	ppe               = db.FloatProperty(required = True)
