###

	The view someone sees the very first time
	they go to the WDS site

	This will appear until their 'intro' count
	is above the number of welcome tabs

###

ap.Views.profile = XView.extend

	initialize: ->
		@options.sidebar = 'profile'
		@options.sidebar_filler = @options.attendee.attributes
		@renderInterests()
		@renderQuestions()
		@options.attendee.set
			pic: @options.attendee.get('pic').replace('_normal', '')
		@options.out = _.template @options.out, @options.attendee.attributes
		@options.out = _.template @options.out, @options.attendee.attributes
		@initRender()
		self = this
	rendered: ->
		setTimeout =>
			@renderMap()
		, 5
	renderQuestions: ->
		questions = [
			'Why did you travel <span class="ceil">{{ distance }}</span> miles to the World Domination Summit'
			'What are you excited about these days?'
			'What\'s your super-power?'
			'What is your goal for WDS 2014?'
		]
		count = 0
		html = ''
		for answer in JSON.parse(@options.attendee.get('answers'))
			html += '<div class="attendee-question-shell">'
			html += '<div class="question">'+questions[count]+'</div><div class="answer">'+answer.answer+'</div>'
			html += '</div>'
			count += 1
		html += '<div class="clear"></div>'
		@options.attendee.set
			questions: html
	renderInterests: ->
		html = ''
		for interest in JSON.parse(@options.attendee.get('interests'))
			interest = ap.Interests.get(interest)
			html += '<a href="/group/'+_.slugify(interest.get('interest'))+'" class="interest-button">'+interest.get('interest')+'</a>'
		html += '<div class="clear"></div>'
		@options.attendee.set
			interests: html

	renderMap: ->
		attendee = @options.attendee.attributes
		profile_map_el = document.getElementById('attendee-profile-map')
		mapOptions = 
			center: new google.maps.LatLng(attendee.lat, attendee.lon)
			zoom: 8
			scrollwheel: false
			disableDefaultUI: true
		profile_map = new google.maps.Map(profile_map_el, mapOptions)
		
	syncAvatar: ->
		if ap.me.get('pic')?
			$('.current-avatar').show()
			$('.avatar-shell').empty().append $('<img/>').attr('src', ap.me.get('pic').replace('_normal', ''))

	whenFinished: ->