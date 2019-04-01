$(document).ready(function () {
  $(document).on('click', '.add-item-to-distribution',function(e) {
    var target = $(e.target)
    var item_quantity = target.parent().parent().children('.item-distribution-quantity').find('.quantity').val()
    target.parent().parent().children('.item-distribution-quantity').find('.quantity').val('')
    var item_upc = target.parent().parent().children('.item-distribution-upc').find('.upc').val()
    target.parent().parent().children('.item-distribution-upc').find('.upc').val('')
    var items_total = target.parent().parent().find('.distribution-total-items').data('total')
    var add_items = target.parent().parent().find('.distributed-item-list')
    var new_remainder = parseInt(items_total) - parseInt(item_quantity)
    add_items.append(`<div>barcode: ${item_upc} item_num: ${item_quantity} </div>`)
    target.parent().parent().find('.distribution-remaining-items').data('remaining', new_remainder)
    target.parent().parent().find('.distribution-remaining-items').empty()
    target.parent().parent().find('.distribution-remaining-items').append(`Remaining: ${new_remainder}`)
  })
})