class BookableHooks < Spree::ThemeSupport::HookListener
  
  insert_after :inside_product_cart_form, 'shared/bookable_date_chooser'
  insert_after :cart_item_description, 'orders/line_item_extra_description'
  replace :order_details_line_item_row, 'shared/bookable_order_line_item_row'
  
end