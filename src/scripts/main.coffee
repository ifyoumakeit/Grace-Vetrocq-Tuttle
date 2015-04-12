window.jQuery = window.$ = require "../bower_components/jquery/dist/jquery.min"

_           = require("../bower_components/underscore/underscore")
RSlides     = require("../bower_components/ResponsiveSlides/responsiveslides")
Tabletop    = require("../bower_components/tabletop/src/tabletop").Tabletop
Velocity    = require("../bower_components/velocity/velocity")
Handlebars  = require("Handlebars")
Marked      = require("marked")

###jslint node: true ###

OnePager =
  $CURRENT: $('#top')

  registerHelpers: ->

    Handlebars.registerHelper 'commalist', (item) ->
      output = ''
      arr = item.split('\n')
      i = 0
      l = arr.length
      while i < l
        output += '<span class="section__tag">' + arr[i] + '</span> '
        i++
      new (Handlebars.SafeString)(output)

    Handlebars.registerHelper 'paragraphSplit', (plaintext) ->
      output = Marked(plaintext)
      new (Handlebars.SafeString)(output)

    Handlebars.registerHelper 'linklist', (item) ->
      arr = item.split('\n')
      output = ''
      output += '<div class="meta">'
      output += "<a href='#{arr[1]}' target='_blank'><i class='fa fa-external-link'></i>#{arr[0]}</a>";
      output += '</div>'
      new (Handlebars.SafeString)(output)

    Handlebars.registerHelper 'imagelist', (item) ->
      output = ''
      arr = item.split('\n')
      i = 0
      l = arr.length
      while i < l
        output += "<li><img src='images/#{arr[i].replace(/\s/g, '')}'/></li>"
        i++
      new (Handlebars.SafeString)(output)


  scrollTo: (e) ->
    e.preventDefault()
    id = $(e.currentTarget).attr('href')

    # Get section
    if id is '#prev'
      @$CURRENT = @$CURRENT.prev('.section')
    else if id is '#next'
      @$CURRENT = @$CURRENT.next('.section')
    else
      @$CURRENT = $(id)


    @$CURRENT.velocity 'scroll',
      easing: 'ease-in-out'
      duration: 500


  growProjects: ->
    $('.section').css 'min-height', $(window).height()
    $('body').removeClass 'is-loading'

  addContactForm: ->
    $('.form__submit').click (e) ->
      e.preventDefault()
      $submit = $(@)
      $name = $('#name')
      $email = $('#email')
      $text = $('#text')
      dataString = 'name=' + $name.val() + '&email=' + $email.val() + '&text=' + $text.val()
      pattern = new RegExp(/^((([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+(\.([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+)*)|((\x22)((((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(([\x01-\x08\x0b\x0c\x0e-\x1f\x7f]|\x21|[\x23-\x5b]|[\x5d-\x7e]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(\\([\x01-\x09\x0b\x0c\x0d-\x7f]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]))))*(((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(\x22)))@((([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.)+(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.?$/i)
      if pattern.test($email.val()) and $name.val().length > 1
        $submit.attr 'data-state', 'loading'
        $.ajax
          type: 'POST'
          url: 'contact.php'
          data: dataString
          success: ->
            $name.val ''
            $email.val ''
            $text.val ''
            $submit.attr 'data-state', 'success'

          error: ->
            $submit.attr 'data-state', 'error'

      else
        $submit.attr 'data-state', 'error'
      false

  addSlider: ->
    $('.section__slider').responsiveSlides
      auto: true
      speed: 500
      timeout: 4000
      pager: true
      nav: true
      pauseControls: true
      namespace: 'section__slider_'

  actionButtons: ->
    $('.nav__link').click @scrollTo.bind(@)

  getPosition: (index, el) ->

    $section = $(el)
    $symbol = $('[data-for=\'' + $section.attr('id') + '\']').find('.nav__symbol')
    top = $section.offset().top
    scrollTop = $(window).scrollTop()

    $symbol.removeClass('top down left')
    if scrollTop < top
      $symbol.addClass 'down'
    else if scrollTop > $section.height() + top
      $symbol.addClass 'up'
    else
      $symbol.addClass 'left'
      @$CURRENT = $section

  actionScroll: ->
    y_scroll_pos = window.pageYOffset
    $nav = $('.nav')

    if y_scroll_pos > 200 and not $nav.is(':animated')
      $nav.addClass 'show-home'
    else
      $nav.removeClass 'show-home'

    $('.section:not(.section--top):not(.section--contact)').each @getPosition.bind(@)

  buildUI: ->
    @addSlider()
    @addContactForm()
    @actionButtons()

    $(window).scroll _.debounce(@actionScroll.bind(@), 100)

  init: (data) ->

    @registerHelpers()
    homeTemplate    = Handlebars.compile $('#home-template').html()
    buttonsTemplate = Handlebars.compile $('#button-template').html()
    entriesTemplate = Handlebars.compile $('#entry-template').html()

    #Add Homepage
    $('.section--contact').before homeTemplate(data.HOME.elements[0])

    #Create Project buttons and entries
    _.each data.PROJECTS.elements, (cat) ->
      $('.section--contact').before entriesTemplate(cat)
      $('.next').before buttonsTemplate(cat)

    @growProjects()
    @buildUI()

$ ->
  Tabletop.init
    key: 'https://docs.google.com/spreadsheet/pub?hl=en_US&hl=en_US&key=1HaEpD-vcbGQxei-Eb-5kZ6Y0h4jYUHJI56ZQ6Nj1-Bg&output=html'
    callback: OnePager.init.bind(OnePager)
