class Dashing.Stmodechange extends Dashing.ClickableWidget
  constructor: ->
    super
    @queryState()

  @accessor 'icon',
    get: -> @['icon'] ? 'tag'
    set: Batman.Property.defaultAccessor.set

  @accessor 'icon-style', ->
    if @isModeSet() then 'icon-active' else 'icon-inactive'

  @accessor 'mode',
    get: -> @_mode ? 'Unknown'
    set: (key, value) -> @_mode = value

  @accessor 'countdown',
    get: -> @_countdown ? 0
    set: (key, value) -> @_countdown = value

  @accessor 'timer',
    get: -> @_timer ? 0
    set: (key, value) -> @_timer = value

  showTimer: ->
    $(@node).find('.icon').hide()
    $(@node).find('.action').hide()
    $(@node).find('.timer').show()

  showIcon: =>
    $(@node).find('.timer').hide()
    $(@node).find('.action').hide()
    $(@node).find('.icon').show()

  showAction: ->
    $(@node).find('.icon').hide()
    $(@node).find('.timer').hide()
    $(@node).find('.action').show()

  isModeSet: ->
    @get('mode') == @get('changemode')

  queryState: ->
    $.get '/smartthings/dispatch',
      widgetId: @get('id'),
      deviceType: 'mode'
      (data) =>
        json = JSON.parse data
        @set 'mode', json.mode

  postModeState: ->
    oldMode = @get 'mode'
    @set 'mode', @get('changemode')
    $.post '/smartthings/dispatch',
      deviceType: 'mode',
      mode: @get('changemode'),
      (data) =>
        json = JSON.parse data
        if json.error != 0
          @set 'mode', oldModeM

  postPhraseState: ->
    $.post '/smartthings/dispatch',
      deviceType: 'phrase',
      phrase: @get('phrase')
      (data) =>
        @queryState()

  ready: ->
    @showIcon()

  onData: (data) ->

  changeModeDelayed: =>
    if @get('timer') <= 0
      @showAction()
      setTimeout(@showIcon, 500)
      if @get('phrase')
        @postPhraseState()
      else
        @postModeState()
      @_timeout = null
    else
      @set 'timer', @get('timer') - 1
      @_timeout = setTimeout(@changeModeDelayed, 1000)

  onClick: (event) ->
    if not @_timeout and not @isModeSet()
      @set 'timer', @get('countdown')
      @changeModeDelayed()
