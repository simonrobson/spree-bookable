require 'test_helper'

class OrderTest < ActiveSupport::TestCase

  context "an order with only bookable products" do
    setup do
      @order = Order.new()
      @p = Factory.create(:product, :bookable => true, :ask_start_date => true)
      @order = Order.create!
      @order.add_variant(@p.variants.first, 2)
    end
    
    should "be all_bookable" do
      assert @order.all_bookable?
    end
    
    should "be intangible" do
      assert @order.intangible?
    end
    
    context "being completed" do
      setup do
        @order.complete
      end

      should "not create a shipment" do
        assert @order.shipments.empty?
      end

    end
    
  end
  
  
  context "an empty order" do
    setup do
      @order = Order.create
    end
    
    should "not be intangible" do
      assert !@order.intangible?
    end
  end
  
  context "an order with mixed bookable and non-bookable products" do
    setup do
      @order = Order.new()
      @p = Factory.create(:product, :bookable => true, :ask_start_date => true)
      @p2 = Factory.create(:product, :bookable => false, :ask_start_date => true)
      @p3 = Factory.create(:product, :bookable => true, :ask_start_date => true)
      @order = Order.create!
      @order.add_variant(@p.variants.first, 4)
      @order.add_variant(@p2.variants.first, 3)
      @order.add_variant(@p3.variants.first, 8)
    end

    should "not be all_bookable" do
      assert !@order.all_bookable?
    end

    should "not be intangible" do
      assert !@order.intangible?
    end

    context "being completed" do
      setup do
        @order.complete
      end

      should "create a shipment" do
        assert !@order.shipments.empty?
      end

    end
  end

end
