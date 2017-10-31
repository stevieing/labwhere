# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).ready ->
  $(".notice").fade 10000
  $(".alert").fade 15000
  $('nav li ul').hide()
  $('nav li').hover(
    -> $('ul', this).stop().slideDown(100),
    -> $('ul', this).stop().slideUp(100)
    )
  $('#location_number_of_locations').on 'input', ->
    $('#locations_range').text($('#location_number_of_locations').val())
  return