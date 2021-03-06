ap.initMobile = ->
	$('body')
	.on('click', '#nav-link-expand', ap.toggleNav)
	$(window).resize(ap.checkMobile)
ap.toggleNav = (force = false) ->
	nav = $('#nav-links')
	state = 'nav-links-open'
	if (typeof force is 'object')
		force.preventDefault()
	if nav.hasClass(state) or (force and typeof force isnt 'object')
		nav.removeClass(state)
	else
		nav.addClass(state)

ap.checkMobile = ->
	width = $(window).outerWidth()
	$wall = $('#waterfall')
	$video = $('#video')
	if width <= 768 and width > 690
		ap.isTablet = ap.isMobile = true
		ap.isPhone = false
	else if width < 690
		ap.isPhone = ap.isMobile = true
		ap.isTablet = false
	else
		ap.isPhone = ap.isTablet = ap.isMobile = false

	if ap.isMobile
		$video.css('height', (width*(9/16)+'px'))
		header = $('#page-home #content_shell #header-title')
		if header
			header.remove()
			$('#logo').after(header)
	else
		header = $('#page-home #main-header #header-title')
		if header
			header.remove()
			$('#content_shell').prepend(header)
