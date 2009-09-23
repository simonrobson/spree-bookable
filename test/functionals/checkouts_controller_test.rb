require 'test_helper'

class CheckoutsControllerTest < ActionController::TestCase
  #fixtures :countries, :states, :gateways, :gateway_configurations
  
  context "given current_user and a regular order" do
    setup do 
      @user = Factory(:user, :email => "test@example.com")
      @controller.stub!(:current_user, :return => @user)
      
      Factory.create(:country, :id => 214, :name => 'United States', :iso_name => 'US')
      
    end
    context "and an order that ships" do
      setup do
        @order = Factory.create(:order)
        @params = { :order_id => @order.number }
        session[:order_id] = @order.id
      end
    
      context "get edit" do
        setup do
          get :edit, @params
        end
        should_respond_with :success
        should_assign_to 'checkout'
      
        should "default the shipping address to something" do
          assert_not_nil assigns('checkout').ship_address
        end
      end
    end
    
    context "and an order contains only bookable producst (so does not ship)" do
      setup do
        @order = Factory.create(:order, :charges => {})
        @p = Factory.create(:product, :bookable => true, :ask_start_date => true)
        @order.add_variant(@p.variants.first, 2)
        @params = { :order_id => @order.number }
        session[:order_id] = @order.id
      end
    
      context "get edit" do
        setup do
          get :edit, @params
        end
        should_respond_with :success
        should_assign_to 'checkout'
      
        should "not default the shipping address to anything" do
          assert_nil assigns('checkout').ship_address
        end
      end
    end
  end
end
