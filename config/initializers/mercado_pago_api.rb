begin
  if Rails.env.production? 
    MercadoPagoApi.configure do |config|
      config.client_id       = CatarseSettings.for_key "mercado_pago_client_id" 
      config.client_secret   = CatarseSettings.for_key "mercado_pago_client_secret"
      config.currency_code   = CatarseSettings.for_key "mercado_pago_currency_code"
    	config.saguaro_percent = CatarseSettings.for_key("mercado_pago_saguaro_percent").to_f 
    	config.owner_percent   = CatarseSettings.for_key("mercado_pago_owner_percent").to_f
    	config.redirect_host   = CatarseSettings.for_key "mercado_pago_redirect_host"
    end
  else
    MercadoPagoApi.configure do |config|
      config.client_id       = 4425314579184076
      config.client_secret   = "uYW9CBr38o71pmgHoo7h4meko6N3hK7d"
      config.currency_code   = "AR"
    	config.saguaro_percent = 0.05
    	config.owner_percent   = 0.06
    	config.redirect_host   = "http://localhost:3000"
    end
    
  end
  
  
rescue Exception => e
  puts "Error configuration Mercado Page"
  puts e.message
end

# ID:8602
#
# Name:marruani
# 
# Short Name: marruani
# 
# Description: test account
# 
# Callback URL: http://www.misitio.com/oauth
# 
# URL: http://apps.mercadolibre.com.ar/marruani
# 
# Secret key: A04jxa0MspGQBs3myPdP23pKkgzQJhK3

# For testing proposes you can use:
# *User MarketPlace*: test.registraciones.cacique+39780959@gmail.com Pass: 40046629
# *User Seller**:* test.registraciones.cacique+51486668@gmail.com Pass: 57848794
# *User Buyer:* test.registraciones.cacique+33375783@gmail.com Pass: 80348989