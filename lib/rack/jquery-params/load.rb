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
      self.class.fix(env, @options[:applies_to])
      @app.call(env)
    end

    def self.fix(env, valid_methods=:all)
      valid_methods = extract_valid_methods(valid_methods)
      return if valid_methods != :all and !valid_methods.include?(env['REQUEST_METHOD'])
      fix_params(env['rack.request.query_hash'])
      raw_rack_input = env['rack.input']
      begin
        params = Rack::Utils.parse_nested_query(env['rack.input'].read, '&')
        fix_params(params)
        env["rack.input"] = StringIO.new(Rack::Utils.build_nested_query(params))
      rescue
        env['rack.input'] = raw_rack_input
      end
    end

    def self.fix_params(params)
      if params.is_a?(Hash)
        return params if params.size == 0
        if params.all?{|k,v| k =~ /^[0-9]+$/}
          sorted_params = params.sort
          valid_index = nil
          return params unless sorted_params.all? do |param|
            (valid_index.nil?) ? valid_index=0 : valid_index+=1
            param[0].to_i == valid_index
          end
          sorted_params.inject([]){|result, v| result << fix_params(v[1]) }
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
