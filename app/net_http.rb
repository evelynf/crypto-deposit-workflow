# TODO write where this is from
# module Coinbase
#     module Exchange
      class Client < APIClient
        def initialize(api_key = '', api_secret = '', api_pass = '', options = {})
          super(api_key, api_secret, api_pass, options)
          @conn = Net::HTTP.new(@api_uri.host, @api_uri.port)
          @conn.use_ssl = true if @api_uri.scheme == 'https'
          @conn.cert_store = self.class.whitelisted_certificates
          @conn.ssl_version = :TLSv1
        end
  
        private

              def post(path, user_id, params = {})
        validate_config_setup!

        params.transform_keys!(&:to_s)
        params['user_id'] = user_id.to_s

        # Make the request
        res = connection.post(path) do |req|
          req.options.timeout          = 5 # open/read timeout in seconds
          req.options.open_timeout     = 5 # connection open timeout in seconds
          req.body = params.to_json
        end

        log_response(res, 'post', path)
        # Return the faraday response
        package(res)
      end

      def delete(path, user_id, params = {})
        validate_config_setup!

        params.transform_keys!(&:to_s)
        params['user_id'] = user_id.to_s

        # Make the request
        res = connection.delete(path) do |req|
          req.options.timeout          = ConfigService.numeric('request_timeout', default: 5) # open/read timeout in seconds
          req.options.open_timeout     = ConfigService.numeric('request_open_timeout', default: 5) # connection open timeout in seconds
          req.body = params.to_json
        end

        log_response(res, 'delete', path)
        package(res)
      end

      def connection
        @connection ||= Faraday.new(url: api_url) do |c|
          c.use(:ddtrace) if CB::Trace.enabled?
          c.request(:json)
          c.request(:pro_admin_sign, secret: api_secret)
          c.response(:json)
          c.adapter(Faraday.default_adapter)
        end
      end
  
        def http_verb(method, path, body = nil)
          case method
          when 'GET' then req = Net::HTTP::Get.new(path)
          when 'POST' then req = Net::HTTP::Post.new(path)
          when 'DELETE' then req = Net::HTTP::Delete.new(path)
          else fail
          end
  
          req.body = body
  
          req_ts = Time.now.utc.to_i.to_s
          signature = Base64.encode64(
            OpenSSL::HMAC.digest('sha256', Base64.decode64(@api_secret).strip,
                                 "#{req_ts}#{method}#{path}#{body}")).strip
          req['Content-Type'] = 'application/json'
          req['CB-ACCESS-TIMESTAMP'] = req_ts
          req['CB-ACCESS-PASSPHRASE'] = @api_pass
          req['CB-ACCESS-KEY'] = @api_key
          req['CB-ACCESS-SIGN'] = signature

          print('req', req)
  
          resp = @conn.request(req)
          case resp.code
          when "200" then yield(NetHTTPResponse.new(resp))
          when "400" then fail BadRequestError, resp.body
          when "401" then fail NotAuthorizedError, resp.body
          when "403" then fail ForbiddenError, resp.body
          when "404" then fail NotFoundError, resp.body
          when "429" then fail RateLimitError, resp.body
          when "500" then fail InternalServerError, resp.body
          end
          resp.body
        end
      end
  
      # Net-Http response object
      class NetHTTPResponse
        def body
          @response.body
        end
  
        def headers
          out = @response.to_hash.map do |key, val|
            [ key.upcase.gsub('_', '-'), val.count == 1 ? val.first : val ]
          end
          out.to_h
        end
  
        def status
          @response.code.to_i
        end
      end
#     end
#   end