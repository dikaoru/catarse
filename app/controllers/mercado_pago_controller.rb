class InvalidProject < StandardError; end
class SuccessfulProject < StandardError; end
class MercadoPagoController < ApplicationController
  
  def show
    @project = Project.find params[:id]
    
    # Is this a response to a project authorization? If so, get a refresh token for future use.
    # There is no point in storing the authorization code; it won't ever be used again.
    if params.key? :code
      MercadoPagoApi.retrieve_initial_refresh_token(@project, params[:code])
      redirect_to project_path(:id => @project.id) and return
    end
    
    render :text => "Calling show out of context"
  end
  
  
  # Called to authenticate the project ower to Mercado Pago. Call simply redirects
  # them to the Mercado Pago authentication page, which in turn calls back into 
  # the Saguaro platform.
  # id = project.id
  # PAIN THE ASS TO TEST!! Just saying.
  def project_auth
    @project = Project.find params[:id]
    url = MercadoPagoApi.format_redirect_uri(@project)
    call = "https://auth.mercadolibre.com.ar/authorization?client_id=#{MercadoPagoApi.client_id}&response_type=code&platform_id=mp&redirect_uri=#{url}"
    redirect_to call
  end
  
    
  def pay
    @contribution = Contribution.find params[:id]

    access_token = MercadoPagoApi.retrieve_access_token(@contribution.project)
    raise "error retrieving access token" if access_token.nil?
    
    response = MercadoPagoApi.set_payment_preferences(@contribution, access_token)
    raise response["message"] if response.key?("status")
    
    if Rails.env.production?
      redirect_to response["init_point"]
    else
      redirect_to response["sandbox_init_point"]
    end
  end
  
  
  def details
    response = MercadoPagoApi.retrieve_payment_details params[:id]
    
    render :text => response.inspect
  end
  
  
  def notification
    response = MercadoPagoApi.retrieve_payment_details params[:id]
    
    # if response.key? "error"
    #   puts "Notification retrieval error"
    #   puts "error =   #{response['error']}"
    #   puts "message = #{response['message']}"
    #   render :text => "Notification error"
    #   return
    # end
    
    # collection = response["collection"]
    # status = collection["status"]
    
    # if status == "approved"
    #   puts "Status approved"
      
    #   collection["external_reference"] =~ /mp-(\d*)-(\d*)/
    #   backer = Backer.find $2
      
    #   if backer.nil?
    #     render :text => "This backer has been removed" and return
    #   end
      
    #   details = PaymentDetail.first :conditions => ["mercado_pago_payment_id=?", collection["id"]]
    #   if details # payment already created, this is an update
    #     puts "updating existing payment"
    #     details.status = status
    #     details.save
        
    #     backer.confirmed = true
    #     backer.confirmed_at = Time.now
    #     backer.display_notice = true
    #     backer.key = collection["id"]
    #     backer.payment_method = "MercadoPago"
    #     backer.save

    #   else # create new payment
    #     puts "creating new payment"
    #     details = PaymentDetail.new
    #     details.backer = backer
    #     details.payer_name = backer.user.full_name
    #     details.payer_email = backer.user.email
    #     details.payment_method = "MercadoPago"
    #     details.net_amount = backer.value
    #     details.total_amount = backer.value
    #     details.payment_status = status
    #     details.payment_date = Time.now
    #     details.mercado_pago_payment_id = collection["id"]
    #     details.save

    #     backer.confirmed = true
    #     backer.confirmed_at = Time.now
    #     backer.display_notice = true
    #     backer.key = collection["id"]
    #     backer.payment_method = "MercadoPago"
    #     backer.save
        
    #   end
    # end
    
    
    
    render :text => "OK, notification received"
  end
  
end
