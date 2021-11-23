require 'time'
require 'base64'
require 'openssl'
require 'faraday'

# Generate headers to be used on API call.
#
# @return [Hash<String, Object>]
def generate_headers(method, path)
  datetime = Time.now.httpdate
  request_line = "#{method} #{path} HTTP/1.1"
  payload = [datetime, request_line].join("\n")
  digest = OpenSSL::HMAC.digest(OpenSSL::Digest.new('sha256'), ENV['MEKARI_API_CLIENT_SECRET'], payload)
  signature = Base64.strict_encode64(digest)

  {
    'Content-Type' => 'application/json',
    'Date' => datetime,
    'Authorization' => "hmac username=\"#{ENV['MEKARI_API_CLIENT_ID']}\", algorithm=\"hmac-sha256\", headers=\"date request-line\", signature=\"#{signature}\""
  }
end

# Set method and path for the request
method = 'POST'
path = '/v2/klikpajak/v1/efaktur/out/'
default_headers = { 'X-Idempotency-Key' => '1234' }
request_headers = default_headers.merge(generate_headers(method, path))

puts "Start request with headers: #{request_headers}"

response = Faraday.post("#{ENV['MEKARI_API_BASE_URL']}/#{path}", nil, request_headers)

puts "Got response with status: #{response.status}, body: #{response.body}"