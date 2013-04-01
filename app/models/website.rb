module Website
  require 'httparty'

  def self.get(method, query=nil)
    result = nil
    begin
      result = HTTParty.get("#{service_url}/#{method}", { :query => query })
    rescue
      Rails.logger.error("Website GET #{service_url}/#{method} ERROR")
    end
    result ? result.parsed_response : nil
  end

  def self.service_url
    url = String.new
    url<< APP_CONFIG["website_base_url"]
    url<< APP_CONFIG["website_service_path"]
    url
  end
end
