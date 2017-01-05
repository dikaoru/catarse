class PaypalController < ApplicationController

  before_filter :initialize_paypal

  def pay
    backer = Backer.find params[:id]
    begin
      paypal_response = @paypal.setup_purchase(backer.value * 100,
                                               :ip => request.remote_ip,
                                               :currency => 'USD',
                                               :description => t('projects.backers.checkout.paypal_description'),
                                               :return_url => success_paypal_url(backer),
                                               :cancel_return_url => cancel_paypal_url(backer),
                                               :allow_guest_checkout => true,
                                               :no_shipping => true,
                                               :items => [{:name => t('projects.backers.checkout.paypal_description'),
                                                           :description => backer.project.name,
                                                           :amount => backer.value * 100}])

      backer.update_attribute :payment_method, 'PayPal'

      redirect_to @paypal.redirect_url_for(paypal_response.token)
      
    # rescue
    #   flash[:failure] = t('projects.backers.checkout.paypal_error')
    #   return redirect_to new_project_backer_path(backer.project)
    # end
  end

  def success
    backer = Backer.find params[:id]
    begin
      details = @paypal.details_for(params[:token])
      #raise details.params['payer_id'].inspect
      checkout = @paypal.purchase(backer.value * 100,
                                   {:token => params[:token],
                                   :payer_id => details.params['payer_id']})

      if checkout.params['payment_status'] == "Completed"
        backer.update_attribute :key, checkout.params['transaction_id']
        backer.update_attribute :payment_token, checkout.params['Token']
        backer.confirm!
        flash[:success] = t('projects.backers.checkout.success')
        redirect_to thank_you_path
      else
        flash[:failure] = t('projects.backers.checkout.paypal_error')
        return redirect_to new_project_backer_path(backer.project)
      end

    #rescue
    #  flash[:failure] = t('projects.backers.checkout.paypal_error')
    #  return redirect_to new_project_backer_path(backer.project)
    end
  end

  def cancel
    backer = Backer.find params[:id]
    flash[:failure] = t('projects.backers.checkout.paypal_cancel')
    redirect_to new_project_backer_path(backer.project)
  end

  protected

  def initialize_paypal
    # TODO: something like Paypal.sandbox! if ENV['PAYPAL_TEST'].present? for production

    if Rails.env.production?
      ::ActiveMerchant::Billing::Base.mode = :production
      @paypal = ::ActiveMerchant::Billing::PaypalExpressGateway.new(
          :login => ::Configuration.find_by_name('paypal_username').value,
          :password => ::Configuration.find_by_name('paypal_password').value,
          :signature => ::Configuration.find_by_name('paypal_signature').value)
    else
      ::ActiveMerchant::Billing::Base.mode = :test
      @paypal = ::ActiveMerchant::Billing::PaypalExpressGateway.new(
          :login => "mike.p_1331825479_biz_api1.gmail.com",
          :password => "1331825504",
          :signature => "A60lxptnm538CNmSqrSFawmyrLfkANtfQPGaSTgDzNOTAaJNXjs-1qNK")
    end
  end
end
