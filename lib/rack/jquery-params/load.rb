require 'rack'

# Loops through all params and convert the hashes to arrays only if all keys are comprised of integers.
module Rack
  class JQueryParams
    include Rack::Utils

    HTTP_METHODS = %w(GET PUT POST DELETE HEAD OPTIONS PATCH)
    ALL = 'ALL'

    def initialize(app, options={})
      @options = options
      @app = app
    end

    def call(env)
      status, headers, response = @app.call(env)

      self.class.fix(env, @options[:applies_to])
      [status, headers, response]
    end

    def self.fix(env, valid_methods=:all)
      valid_methods = extract_valid_methods(valid_methods)
      return if valid_methods != :all and !valid_methods.include?(env['REQUEST_METHOD'])
      fix_params(env['rack.request.query_hash'])
      fix_params(env['rack.request.form_hash'])
    end

    def self.fix_params(params)
      if params.is_a?(Hash)
        if params.all?{|k,v| k =~ /^[0-9]+$/}
          params.sort.inject([]){|result, v| result << fix_params(v[1]) }
        else
          params.each{|k,v| params[k] = fix_params(v) }
        end
      elsif params.is_a?(Array)
        params.each_with_index {|v,i| params[i] = fix_params(v) }
        return params
      else
        return params
      end
    end

    def self.extract_valid_methods(object)
      valid_methods = []
      if object.is_a?(Array)
        object.each do |a|
          a = a.to_s.upcase
          break valid_methods = [] if a == 'ALL'
          valid_methods << a if HTTP_METHODS.include?(a)
        end
      else
        method = object.to_s.upcase
        valid_methods = [method] if HTTP_METHODS.include?(method)
      end
      (valid_methods.size > 0) ? valid_methods : :all
    end

  end

end
