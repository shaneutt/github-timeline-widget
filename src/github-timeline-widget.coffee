jQuery.fn.githubTimelineWidget = (options) ->
  defaults =
    username: 'timeline'
    limit: 5
    user_id: true

  # Determine where the stylesheet is located (relative to the location of this script)
  scripts = document.getElementsByTagName 'script'
  for script in scripts
    if script.src?.match /github-timeline-widget\.js/
      script_path = script.src.replace /github-timeline-widget\.js.*$/, ''
      break

  # Load stylesheet
  if script_path?
    jQuery('<link/>')
    .attr('rel', 'stylesheet')
    .attr('type', 'text/css')
    .attr('href', script_path + 'github-timeline-widget.css')
    .prependTo('head');

  this.each ->
    it = this
    $this = jQuery(this)

    # Merge default options
    it.opts = jQuery.extend {}, defaults, options

    # Add heading
    jQuery('<a>')
      .attr('class', 'github-timeline-header')
      .attr('href', "https://github.com/#{it.opts.username}")
      .text("#{it.opts.username} on GitHub")
      .appendTo($this)

    # Add list
    list = jQuery('<ul>')
      .attr('class', 'github-timeline-events')
      .appendTo($this)

    api = new GitHubTimelineApi
    api.getTimelineForUser it.opts.username, (events) ->
      events_left = it.opts.limit
      for event in events
        # Only print up to limit events
        if events_left-- == 0
          break

        # Splat out components
        [url, icon_url, timestamp, text] = event
        
        list_item = jQuery('<li>')
          .attr('class', 'github-timeline-event')
          .appendTo(list)

        event_link = jQuery('<a>')
          .attr('href', url)

        if icon_url
          jQuery('<img>')
            .attr('src', icon_url)
            .appendTo(list_item)
            .wrap(jQuery('<div>').attr('class', 'github-timeline-event-icon'))
            .wrap(event_link)

        div_text = jQuery('<div>')
          .attr('class', 'github-timeline-event-text')
          .html(text)
          .appendTo(list_item)
          .wrapInner(event_link)

        if timestamp
          timestamp_ago = api.formatAsTimeAgo new Date(timestamp)
          if timestamp_ago
            jQuery('<div>')
              .attr('class', 'github-timeline-event-time')
              .text(timestamp_ago)
              .appendTo(div_text)

      # Footer (bylines)
      jQuery('<a>')
        .attr('class', 'github-timeline-source-link')
        .attr('href', 'https://github.com/alindeman/github-timeline-widget')
        .text('GitHub Timeline Widget')
        .appendTo($this)

    # Add user ID
    if it.opts.user_id
      api.getUserIdForUser it.opts.username, (user_id) ->
        jQuery('<br/>')
          .appendTo('.github-timeline-header')

        jQuery('<span>')
          .attr('class', 'github-timeline-header-user-id')
          .text("(user ##{user_id})")
          .appendTo('.github-timeline-header')
