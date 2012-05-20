class Wepay::CheckoutController < Wepay::ApplicationController
  def index    
    is_preapproval = params[:preapproval_id].present?
        
    record = is_preapproval ? WepayCheckoutRecord.find_by_preapproval_id_and_security_token(params[:preapproval_id],params[:security_token]) : WepayCheckoutRecord.find_by_checkout_id_and_security_token(params[:checkout_id],params[:security_token])
    
    if record.present?
      wepay_gateway = WepayRails::Payments::Gateway.new
      checkout = is_preapproval ? wepay_gateway.lookup_preapproval(record.preapproval_id) : wepay_gateway.lookup_checkout(record.checkout_id)
      record.update_attributes(checkout)
      redirect_to is_preapproval ? "#{wepay_gateway.configuration[:after_checkout_redirect_uri]}?preapproval_id=#{params[:preapproval_id]}" : "#{wepay_gateway.configuration[:after_checkout_redirect_uri]}?checkout_id=#{params[:checkout_id]}"
    else
      raise StandardError.new("Wepay IPN: No record found for checkout_id #{params[:checkout_id]} and security_token #{params[:security_token]}")
    end
  end
end