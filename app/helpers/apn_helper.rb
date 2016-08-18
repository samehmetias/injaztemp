module ApnHelper
  class Apn

  	def sendAlert token, title, sound, is_android
  		APNS.host = 'gateway.push.apple.com' 
    	APNS.pem  = 'config/certs/apn_production.pem'
      # APNS.pem  = 'config/certs/apn_development.pem'
    	APNS.port = 2195
    	gcm = GCM.new("AIzaSyBbUoVr1Owunr9-vDUPsrPQlsHjEEujgxA")
  		if is_android
  			options = {data: {title: title, message: ""}}
            response = gcm.send([token], options)
  		else
  			APNS.send_notification(token, :alert => title, :badge => 1, :sound => sound)
  		end
  	end

  end
end