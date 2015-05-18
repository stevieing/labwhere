$.fn.fade = (time) -> this.fadeOut time

jQuery ->
  $('.container').on 'click', '.add-data', (event) ->
    $this = $(this)
    event.preventDefault()
    $.ajax
      url: $this.data('path')
      dataType: "html"
      success: (data, textStatus, jqXHR) ->
        $($this).parent().after($(data).find("#collection"))

$.fn.addDialog = (partial, title) ->
  this.dialog
    autoOpen: true
    height: 300
    width: 600
    title: title
    open: -> $(this).html(partial)
    buttons:
      Cancel: -> $(this).dialog("close")