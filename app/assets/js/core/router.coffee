window.Router = Backbone.Router.extend
	routes:
		"*actions": "defaultRoute"
	before: ->
	defaultRoute: (actions) ->
		# If no action, figure it out
		if (actions is '')
			if (ap.authd)
				actions = 'home';
			else
				actions = 'login';
		ap.goTo(actions)
	logout: ->
		ap.nav 'login'
		_.a 'logout', {}, (rsp) ->
		localStorage.clear()
		@stop

ap.initd = false
ap.loadingTimos = []

###
# Show Loading
###
ap.loading = ->
	ap.loadingTimos.push setTimeout ->
		ap.goTo 'loading'
	, 50

###
#  Change the URL and trigger a page change
###
ap.nav = (uri) ->
	Backbone.history.navigate uri, {trigger: true}

###
# This re-renders the page to show new content
###
ap.goTo = (panel = '', options = {}) ->
	# Go to the panel
	if panel isnt 'loading'
		for timo in ap.loadingTimos
			clearTimeout(timo)
	panel = if panel and panel.length then _.trim(panel, '/') else 'home'
	$s = $('#')
	ap.onPanel = panel
	view = ap.Views[panel] ? ap.Views.default
	if ap.currentView?
		ap.currentView.unbind()
		ap.currentView.undelegateEvents()
	$('#content_shell').attr('class', '')
	options.el = $('#content_shell')
	options.out = ap.templates['pages_'+panel] + '<div class="clear"></div>'
	options.render = 'replace'
	options.view = panel
	setTimeout ->
		ap.currentView = new view options
	, 120
	$('body').attr('id', 'page-'+panel)

ap.back = ->
	history.go(-1);
	return false;