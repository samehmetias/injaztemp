module Api
  class BaseController < ApplicationController
    $api_datetime_format = "%d %b, %Y %I:%M:%S %p"
    $api_date_format = "%Y-%m-%d"
    @@current_user = ""
    protect_from_forgery with: :null_session
    respond_to :json
    # check request format and access restrictions
    before_filter :restrict_access
    # Remove Can't verify CSRF token authenticity warning
    skip_before_filter  :verify_authenticity_token

    # Logging each request data
    after_filter do
      logger.info "RESPONSE: " + response.body
    end

    # Rescue from 404 routing errors
    def catch_404
      render :json => { :success => "0", :message => "API Doesn't Exist!" }, :status => 404
    end
    def self.current_user
      @@current_user
    end
    # Rescue from format error
    # User's request is not json
    # Content-Type is application/vdn.wellspring.v{@version},application/json
    rescue_from  ActionController::UnknownFormat do |e|
      render :json => { :success => "0", :message => "API Request Must Be JSON" }, :status => 400
    end

    private
    # Access Restrictions by parameters
    def restrict_access
      return unless ((restrict_access_by_header || restrict_access_by_params) && :verify_authenticity_token)
      @@current_user = @api_key.user if @api_key
    end

    # Access Restrictions by headers
    def restrict_access_by_header
      return false if request.headers["HTTP_AUTHORIZATION"].nil?
      return true if @api_key
      token = request.headers["HTTP_AUTHORIZATION"].gsub(/Token realm=/,'').gsub(/Token token=/,'').gsub('"','')
      if token.nil?
        token = params[:userToken]
      else
        return false if !(token == params[:userToken])
      end
      @api_key = ApiKey.find_by_key(token)
    end

    def restrict_access_by_params
      
      return true if @api_key
      authenticate_or_request_with_http_token do |token, options|
        ApiKey.exists?(key: token)
      end
      @@current_user = @api_key.user if @api_key
    end

    protected
    def request_http_token_authentication(realm = "Application")
      self.headers["HTTP_AUTHORIZATION"] = %(Token realm="#{realm.gsub(/"/, "")}")
      render :json => {:success=>"0",:message => "Access denied"}, :status => :unauthorized
    end

  end
end
# /app/controllers/api/base_controller.rb
