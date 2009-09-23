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
      {:name => 'Bookable', :only => [:product]},
      {:name => 'Ask Start Date', :only => [:product]},
      {:name => 'Ask End Date', :only => [:product]}
    ]
    
    # Customise the Order model

    Order.class_eval do
      def all_bookable?
        return false if self.line_items.empty?
        self.line_items.all?{|li| li.product.bookable?}
      end
      
      #
      # would like to see this in core. General 
      # flag for orders that done' need to be shipped.
      #
      def intangible?
        self.all_bookable?
      end
      
      #
      # do not create a shipment if there are no goods to ship
      #
      #private
      #def complete_order
      #  unless self.intangible? 
      #    shipments.build(:address => ship_address, :shipping_method => checkout.shipping_method)
      #  end
      #  checkout.update_attribute(:completed_at, Time.now)
      #  InventoryUnit.sell_units(self)
      #  save_result = save! 
      #  if email 
      #    OrderMailer.deliver_confirm(self)
      #  end     
      #  save_result
      #end
      
    end


    # Customise the order controller's creat.after procedure to record
    # start and end dates on the line items for bookable products

    OrdersController.class_eval do
      create.after do    
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
    
    #
    # update Checkout controller to 
    # set shipping address to nil if order contains only bookables
    #
    CheckoutsController.class_eval do
      private
      def object
        return @object if @object
        @object = parent_object.checkout                                                  
        unless params[:checkout] and params[:checkout][:coupon_code]
          # do not create these defaults if we're merely updating coupon code, otherwise we'll have a validation error
          if user = parent_object.user || current_user
            @object.shipment.address ||= (parent_object.intangible?) ? nil : user.ship_address 
            @object.bill_address     ||= user.bill_address
          end
          @object.shipment.address ||= (parent_object.intangible?) ? nil : Address.default
          @object.bill_address     ||= Address.default
          @object.creditcard       ||= Creditcard.new(:month => Date.today.month, :year => Date.today.year)
        end
        @object         
      end
      
      
      #def object
      #  return @object if @object
      #  default_country = Country.find Spree::Config[:default_country_id]
      #  @object = parent_object.checkout                                                  
      #  unless params[:checkout] and params[:checkout][:coupon_code]
      #    # do not create these defaults if we're merely updating coupon code, otherwise we'll have a validation error
      #    @object.ship_address ||= (parent_object.intangible?) ? nil : Address.new(:country => default_country)
      #    @object.bill_address ||= Address.new(:country => default_country)   
      #    @object.creditcard   ||= Creditcard.new(:month => Date.today.month, :year => Date.today.year)
      #  end
      #  @object         
      #end
      
      
    end


    # Add your extension tab to the admin.
    # Requires that you have defined an admin controller:
    # app/controllers/admin/yourextension_controller
    # and that you mapped your admin in config/routes

    #Admin::BaseController.class_eval do
    #  before_filter :add_yourextension_tab
    #
    #  def add_yourextension_tab
    #    # add_extension_admin_tab takes an array containing the same arguments expected
    #    # by the tab helper method:
    #    #   [ :extension_name, { :label => "Your Extension", :route => "/some/non/standard/route" } ]
    #    add_extension_admin_tab [ :yourextension ]
    #  end
    #end

    # make your helper avaliable in all views
    # Spree::BaseController.class_eval do
    #   helper YourHelper
    # end
  end
end
