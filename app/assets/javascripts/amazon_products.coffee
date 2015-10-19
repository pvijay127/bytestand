
$(document).on('click', '.parent-icon', (e) ->
  parent_id = $(e.target).data('parentId')
  $(".variant[data-parent-id='#{parent_id}']").toggle()
)
