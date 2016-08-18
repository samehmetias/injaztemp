class ApiConstraints
  def initialize(options)
    @version = options[:version]
    @default = options[:default]
  end

  def matches?(req)
    @default || (!req.headers['APIV'].nil? && req.headers['APIV'].include?("application/vnd.injaz.v#{@version}"))
  end
end
