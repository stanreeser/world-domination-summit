###

	The Router and routes are defined here
	the functions that handle routes are in
	/app/assets/js/routes

###

###
	Create the router
###
ap.createRouter = ->
	window.Router = Backbone.Router.extend
		protect: [
			'hub', 'welcome', 'settings'
		]
		initialize: ->
			@route("*actions", 'default', ap.Routes.defaultRoute)
			@route(/^[0-9a-z]{40}$/, 'hash', ap.Routes.hashLogin)
			@route("logout", 'logout', ap.Routes.logout)
			@route("reset-password/:hash", 'reset', ap.Routes.reset)
			@route("interest/:interest", 'interest', ap.Routes.interest)
			@route("your-transfer/:transfer_id", 'reset', ap.Routes.your_transfer)
			@route("hub", 'hub', ap.Routes.hub)
			@route(/^~(.)+/, 'profile', ap.Routes.profile)
		before: ap.Routes.before


###--

	The following functions are vital
	to the routing process

--###

###
	Show Loading
###
ap.loading = (fade = false) ->
	content = $('#page_content')
	loading = $('#loading')
	loading
		.css
			left: content.offset().left+'px'
			top: content.offset().top+'px'
			width: content.width()+'px'
			height: content.height()+'px'
	if fade
		loading.addClass('loading-faded')
	loading.addClass('is-loading')

ap.loaded = ->
	$('#loading').attr('class', '')

###
	Check if a user is logged in
	Obviously not very secure but real protection
	happens server-side to be sure a logged-out user
	can't get or save anything protected
###
ap.protect = ->
	return ap.me? and ap.me


ap.login = (me) ->
	$('html').addClass('is-logged-in')
	ap.me = new ap.User(me)

### 
	Navigate to a new URL using push-state
###
ap.navigate = (panel) ->
	ap.Router.navigate(ap.getPanelPath(panel), {trigger: true})

ap.getPanelPath = (panel) ->
	map = 
		home: ''
	return '/' + (map[panel] ? panel)

ap.syncNav = (panel) ->
	$('.nav-link-active').removeClass('nav-link-active')
	$('#nav-'+panel).addClass('nav-link-active')
	ap.toggleNav(true)

###
	Re-render the page to show new content
###
ap.goTo = (panel = '', options = {}, cb = false) ->
	# Go to the panel
	panel = if panel and panel.length then _.trim(panel, '/') else 'home'
	$s = $('#')
	ap.onPanel = panel
	view = ap.Views[panel.replace('-', '_')] ? ap.Views.default
	if ap.currentView?
		ap.currentView.unbind()
		ap.currentView.undelegateEvents()
	$('#content_shell').attr('class', '')
	options.el = $('#content_shell')
	if ap.templates['pages_'+panel]?
		tpl = 'pages_'+panel
	else
		tpl = 'pages_404'
	options.out = ap.templates[tpl] + '<div class="clear"></div>'
	options.render = 'replace'
	options.view = panel
	setTimeout ->
		if panel is 'home'
			$('#logo-waves').hide()
		else
			$('#logo-waves').show()
		$('body').attr('id', 'page-'+panel)
		if ap.currentView? and ap.currentView
			ap.currentView.finish()
		ap.currentView = new view options
		$.scrollTo 0
		ap.syncNav(panel)
		ap.checkMobile()

		if cb 
			cb()
	, 120

ap.back = ->
	history.go(-1);
	return false;