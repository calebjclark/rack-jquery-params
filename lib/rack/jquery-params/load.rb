require 'rack'

module Rack
  class JQueryParams
    include Rack::Utils

    VALID_HTTP_METHODS = %w(HEAD PUT POST DELETE OPTIONS PATCH)
    ALL = 'ALL'

    def initialize(app, options={})
      applies_to = []
      if options[:apply_to].is_a?(Array)
        options[:apply_to].each do |a|
          a = a.to_s.upcase
          break applies_to = [] if a == 'ALL'
          applies_to << a if VALID_HTTP_METHODS.include?(a)
        end
      else
        apply_to = options[:apply_to].to_s.upcase
        applies_to = [apply_to] if VALID_HTTP_METHODS.include?(apply_to)
      end
      @applies_to = (applies_to.size > 0) ? applies_to : :all
      @app = app
    end

    # Loops through all params and convert the hashes to arrays only if all keys are comprised of integers.
    #
    def call(env)
      status, headers, response = @app.call(env)

      self.class.fix(env, @applies_to)
      [status, headers, response]
    end

    def self.fix(env, applies_to)
      if applies_to == :all or applies_to.include?(env['REQUEST_METHOD'])
        env['rack.request.query_hash'].each do |key,value|
          next if !value.is_a?(Hash)
          next if !value.all? {|k,v| k =~ /^[0-9]+$/ }
          env['rack.request.query_hash'][key] = value.sort.inject([]) {|result, v| result << v[1] }
        end
      end
    end

  end

end
