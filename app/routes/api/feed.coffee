_ = require('underscore')
redis = require("redis")
rds = redis.createClient()
twitterAPI = require('node-twitter-api')
moment = require('moment')
crypto = require('crypto')

routes = (app) ->

	[Feed, Feeds] = require('../../models/feeds')
	[FeedComment, FeedComments] = require('../../models/feed_comments')

	feed =
		add: (req, res, next) ->
			if req.me
				post = _.pick req.query, Feed.prototype.permittedAttributes
				post.user_id = req.me.get('user_id')

				# Check if this is a duplicate post
				uniq = moment().format('YYYY-MM-DD HH:mm') + post.content + post.user_id
				post.hash = crypto.createHash('md5').update(uniq).digest('hex')
				Feed.forge
					hash: post.hash

				.fetch()
				.then (existing) ->
					if not existing
						feed = Feed.forge post
						feed
						.save()
						.then (feed) ->
							next()
					else
						res.r.msg = 'You already posted that!'
						res.status(409)
						next()
			else
				res.r.msg = 'You\'re not logged in!'
				res.status(401)
				next()

		add_comment: (req, res, next) ->
			if req.me
				post = _.pick req.query, FeedComment.prototype.permittedAttributes
				post.user_id = req.me.get('user_id')

				# Check if this is a duplicate post
				uniq = moment().format('YYYY-MM-DD HH:mm') + post.comment + post.user_id
				post.hash = crypto.createHash('md5').update(uniq).digest('hex')
				FeedComment.forge
					hash: post.hash
				.fetch()
				.then (existing) ->
					if not existing
						comment = FeedComment.forge post
						comment
						.save()
						.then (comment) ->
							Feed.forge({feed_id: req.query.feed_id})
							.fetch()
							.then (feed) ->
								feed.set({num_comments: (feed.get('num_comments') + 1)})
								.save()
								.then (feed) ->
										next()
								, (err) ->
									tk err
					else
						res.r.msg = 'You already posted that!'
						res.status(409)
						next()
			else
				res.r.msg = 'You\'re not logged in!'
				res.status(403)
				next()

		upd: (req, res, next) ->
			feed.add(req,res,next)

		del: (req, res, next) ->
			if req.me
				if req.query.feed_id?
					Feed.forge req.query.feed_id
					.fetch()
					.then (feed) ->
						if feed.get('user_id') is req.me.get('user_id')
							feed.destroy()
							.then ->
								next()
				else
					res.r.msg = 'No feed item sent'
					res.status(400)
					next()
			else
				res.r.msg = 'You\'re not logged in!'
				res.status(403)
				next()

		get: (req, res, next) ->
			feeds = Feeds.forge()
			feeds.query('orderBy', 'feed_id',  'DESC')
			if req.query.since?
				feeds.query('where', 'feed_id', '>', req.query.since)
			feeds
			.fetch()
			.then (feed) ->
				res.r.feed_contents = feed.models
				next()

		get_comments: (req, res, next) ->
			comments = FeedComments.forge()
			comments.query('orderBy', 'feed_comment_id',  'DESC')
			comments.query('where', 'feed_id', '=', req.query.feed_id)
			if req.query.since?
				comments.query('where', 'feed_comment_id', '>', req.query.since)
			comments
			.fetch()
			.then (result) ->
				res.r.comments = result.models
				res.r.num_comments = result.models.length
				next()
			, (err) ->
				tk err

module.exports = routes