# Uncomment this if you reference any of your controllers in activate
# require_dependency 'application'

class BookableExtension < Spree::Extension
  version "1.0"
  description "Allows products to be bookable."
  url ""

  # Please use bookable/config/routes.rb instead for extension routes.

  # def self.require_gems(config)
  #   config.gem "gemname-goes-here", :version => '1.2.3'
  # end
  
  def activate
    
    Variant.additional_fields += [
      {:name => 'Bookable', :use => 'check_box', :only => [:product]},
      {:name => 'Ask Start Date', :use => 'check_box', :only => [:product]},
      {:name => 'Ask End Date', :use => 'check_box', :only => [:product]}
    ]
    
    # Customise the Order model

   Order.class_eval do
      def all_bookable?
        return false if self.line_items.empty?
        self.line_items.all?{|li| li.product.bookable?}
      end
      
      #
      # would like to see this or similar in core. General 
      # flag for orders that don't need to be shipped.
      #
      def intangible?
        self.all_bookable?
      end
      
    end


    # Customise the order controller's create.before procedure to record
    # start and end dates on the line items for bookable products

  
   OrdersController.class_eval do
        def create_before    
        params[:products].each do |product_id,variant_id|
          quantity = params[:quantity].to_i if !params[:quantity].is_a?(Array)
          quantity = params[:quantity][variant_id].to_i if params[:quantity].is_a?(Array)
          if quantity > 0
            v = Variant.find(variant_id)
            @order.add_variant(v, quantity)
            add_dates_to_variant_line_item(v, params[:start_date], params[:end_date])
          end
        end if params[:products]

        params[:variants].each do |variant_id, quantity|
          quantity = quantity.to_i
          if quantity > 0
            v = Variant.find(variant_id)
            @order.add_variant(v, quantity) 
            add_dates_to_variant_line_item(v, params[:start_date], params[:end_date])
          end
        end if params[:variants]

        @order.save

        # store order token in the session
        session[:order_token] = @order.token
      end
  
      
      def add_dates_to_variant_line_item(variant, start_date, end_date)
        li = @order.contains?(variant)
        li.start_date = start_date if (start_date && variant.product.ask_start_date?)
        li.end_date = end_date if (end_date && variant.product.ask_end_date?)
        li.save if li.changed?
      end
    end
    
  end
end
