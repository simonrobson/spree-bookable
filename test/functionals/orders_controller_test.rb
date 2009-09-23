require 'test_helper'

class OrdersControllerTest < ActionController::TestCase

  context "posting to CREATE with details for a bookable product" do
    setup do
      @product = Factory.create(:product, :bookable => true, :ask_start_date => true, :ask_end_date => true)
      @variant = @product.variants.first
      post :create, :variants => {@variant.id.to_s => 2}, :start_date => '23-11-2009', :end_date => '12-12-2009'
    end
    
    should_change "LineItem.count", :by => 1
    should "set the start and end date on the new line item" do
      @li = assigns(:order).line_items.first
      assert_equal @product, @li.product
      assert_equal Date.new(2009, 11, 23), @li.start_date
      assert_equal Date.new(2009, 12, 12), @li.end_date
    end
    
  end

end
