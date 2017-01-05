require 'rubygems'
require 'uri'
require 'json'
require 'net/http'
require 'net/https'
require 'cgi'

API_URL = "https://api.mercadolibre.com"


class MercadoPagoApi
  
  class << self
    attr_accessor :client_id, :client_secret, :currency_code
    attr_accessor :access_token, :auth_code
    attr_accessor :saguaro_percent, :owner_percent
    attr_accessor :redirect_host
    
    def configure(&block)
      yield self if block_given?
    end
    
    
    # Builds the URI that must be the same between calls to Mercado Pago API
    def format_redirect_uri(project, path = nil)
      url = "#{@redirect_host}/mercado_pago/#{project.id}"

      if path
        url += "/#{path}"
      end
      url
    end
    
    
    def retrieve_marketplace_token
      response = service_call "oauth/token", :form, :client_id => client_id, :client_secret => client_secret, 
        :grant_type => "client_credentials"

      response["access_token"]
    end

    
    # Retrieves the first-time use refresh_token for this project. This expires the 
    # authorization_code.
    def retrieve_initial_refresh_token(project, authorization_code)
      response = service_call "oauth/token", :form, :client_id => client_id, :client_secret => client_secret, 
        :grant_type => "authorization_code", :code => authorization_code,
        :redirect_uri => format_redirect_uri(project)
        
      project.update_attribute :mercado_pago_refresh_token, response["refresh_token"]
      
      response
    end
    
    
    # Retrieves an access token, for use in payment_preferences. This expires the refresh token used,
    # so save the new refresh_token for the next payment
    def retrieve_access_token(project)
      response = service_call "oauth/token", :form, :client_id => client_id, :client_secret => client_secret, 
        :refresh_token => project.mercado_pago_refresh_token, :grant_type => "refresh_token"
      raise "error retrieving access token" if  response["refresh_token"].nil?

      project.update_attribute :mercado_pago_refresh_token, response["refresh_token"]
      
      response["access_token"]
    end
    
    
    def retrieve_payment_details(payment_id)
      token = retrieve_marketplace_token
      
      uri = URI.parse "#{API_URL}/collections/notifications/#{payment_id}?access_token=#{token}"
      request = Net::HTTP::Get.new uri.request_uri
      
      http = Net::HTTP.new uri.host, uri.port
      http.use_ssl = true
      http.set_debug_output $stdout
      
      response = http.start do 
        http.request request
      end
      
      puts response.code
      puts response.inspect
      
      JSON.parse(response.body)

    end
    
    
    def set_payment_preferences(contribution, access_token)
      
      uri = URI.parse "#{API_URL}/checkout/preferences?access_token=#{access_token}"

      request = Net::HTTP::Post.new uri.request_uri
      # For DEBUG only, generates a lot of output
      # request.set_debug_output $stdout
      request.content_type = "application/json"
      request.body = contribution.as_mercado_pago_params.to_json
      
      http = Net::HTTP.new uri.host, uri.port
      http.use_ssl = true
      # http.set_debug_output $stdout
      
      response = http.start do 
        http.request request
      end
      
      JSON.parse(response.body)
    end
    
    
    
private
    
    # Makes an API call into the Mercado Pago gateway
    # * call - the URI path of the call
    # * content_type - specifies how params should be presented, as :json or :form
    # * params - parameters to the service call
    # Returns a ruby hash converted from the json results
    def service_call(call, content_type = :form, params = {})
      url = URI.parse "#{API_URL}/#{call}"
      
      case content_type
      when :json
        content_type_str = "application/json"
        params = params.to_json
      when :form
        content_type_str = "application/x-www-form-urlencoded"
      else
        raise "Unexpected content_type value"
      end
      
      call = Net::HTTP::Post.new url.path, { "Accept" => "application/json", "Content-Type" => content_type_str }
      
      case content_type
      when :json
        call.body = params.to_json
      when :form
        call.set_form_data params
      when :inline
        url_params = "?" + params.keys.map { |k| "#{k}=#{params[i]}" }.join("&")
      end
      
  		request = Net::HTTP.new(url.host, url.port)
  		request.use_ssl = true

      # Enable logging for protocol snooping during dev, don't use in production
  		request.set_debug_output $stdout

  		response = request.start { |http| http.request(call) }
      JSON.parse(response.body)
    end
  end
  
end