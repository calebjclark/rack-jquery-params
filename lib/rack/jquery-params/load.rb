require 'rack'

module Rack
  class JQueryParams
    include Rack::Utils

    HTTP_METHODS = %w(GET PUT POST DELETE HEAD OPTIONS PATCH)
    ALL = 'ALL'

    def initialize(app, options={})
      @options = options
      @app = app
    end

    # Loops through all params and convert the hashes to arrays only if all keys are comprised of integers.
    #
    def call(env)
      status, headers, response = @app.call(env)

      self.class.fix(env, @options[:applies_to])
      [status, headers, response]
    end

    def self.fix(env, valid_methods=:all)
      valid_methods = extract_valid_methods(valid_methods)
      return if valid_methods != :all and !valid_methods.include?(env['REQUEST_METHOD'])
      fix_param(env['rack.request.query_hash'])
      fix_param(env['rack.request.form_hash'])
    end

    def self.fix_param(param)
      if param.is_a?(Hash)
        if param.all?{|k,v| k =~ /^[0-9]+$/}
          param.sort.inject([]){|result, v| result << fix_param(v[1]) }
        else
          param.each{|k,v| param[k] = fix_param(v)}
        end
      elsif param.is_a?(Array)
        param.each_with_index {|v,i| param[i] = fix_param(v) }
        return param
      else
        return param
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
