module CheckoutsHelper
  def checkout_steps                                                      
    checkout_steps = %w{registration billing shipping shipping_method payment confirmation}
    checkout_steps.delete "registration" if current_user
    if @order.intangible?
      checkout_steps.delete "shipping"
      checkout_steps.delete "shipping_method"
    end
    checkout_steps
  end
end
