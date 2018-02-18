class ExtensionJob < ApplicationJob
  include ActiveJobRetriesCount
  require 'net/http'
  require 'uri'

  queue_as :default

  def perform(url, items, auth_params)
    uri = URI.parse(url)

    http = Net::HTTP.new(uri.host, uri.port)
    req = Net::HTTP::Post.new(uri.request_uri, 'Content-Type' => 'application/json')
    req.body = {:items => items, :auth_params => auth_params}.to_json
    http.use_ssl = (uri.scheme == "https")
    response = http.request(req)

    if response.code[0] != '2'
      puts "Error performing ExtensionJob"
      retry_job wait: 5.seconds if retries_count < 1
    end
  end
end
