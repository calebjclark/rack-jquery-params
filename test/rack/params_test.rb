require 'test_helper'
require 'rack/jquery-params'

describe 'params' do

  def create_env
    {
        'rack.request.query_hash' => {},
        'rack.request.form_hash' => {},
        'REQUEST_METHOD' => 'POST'
    }
  end

  it 'should ignore hashes that have non-integers in the key' do
    env = create_env.merge('rack.request.query_hash' => {non_array: {'0' => 'is integer', '1' => 'is integer', 'a' => 'is not integer'}})
    Rack::JQueryParams.fix(env, :all)
    assert env['rack.request.query_hash'][:non_array].is_a?(Hash)
  end

  it 'should convert first-level hashes that resembles an array' do
    env = create_env.merge('rack.request.query_hash' => {array: {'0' => 'is integer', '1' => 'is integer', '2' => 'is integer'}})
    Rack::JQueryParams.fix(env, :all)
    assert env['rack.request.query_hash'][:array].is_a?(Array)
  end

  it 'should convert any level of hash that resembles an array' do
    env = create_env.merge('rack.request.query_hash' => {non_array: {'a' => 'is not integer', :array => {'0' => 'is integer', '1' => 'is integer'}}})
    Rack::JQueryParams.fix(env, :all)
    assert env['rack.request.query_hash'][:non_array][:array].is_a?(Array)
  end

  it 'should fix query_hash or form_hash' do
    env = create_env.merge('rack.request.query_hash' => {array: {'0' => 'is integer', '1' => 'is integer', '2' => 'is integer'}})
    Rack::JQueryParams.fix(env, :all)
    assert env['rack.request.query_hash'][:array].is_a?(Array)

    env = create_env.merge('rack.request.form_hash' => {array: {'0' => 'is integer', '1' => 'is integer', '2' => 'is integer'}})
    Rack::JQueryParams.fix(env, :all)
    assert env['rack.request.form_hash'][:array].is_a?(Array)
  end

  it 'should apply to all methods' do
    env = create_env.merge('rack.request.form_hash' => {array: {'0' => 'is integer', '1' => 'is integer', '2' => 'is integer'}})
    env['REQUEST_METHOD'] = 'POST'
    Rack::JQueryParams.fix(env, :all)
    assert env['rack.request.form_hash'][:array].is_a?(Array)

    env = create_env.merge('rack.request.query_hash' => {array: {'0' => 'is integer', '1' => 'is integer', '2' => 'is integer'}})
    env['REQUEST_METHOD'] = 'GET'
    Rack::JQueryParams.fix(env, :all)
    assert env['rack.request.query_hash'][:array].is_a?(Array)
  end

  it 'should allow apply to a single methods' do
    env = create_env.merge('rack.request.query_hash' => {array: {'0' => 'is integer', '1' => 'is integer', '2' => 'is integer'}})
    env['REQUEST_METHOD'] = 'GET'
    Rack::JQueryParams.fix(env, :get)
    assert env['rack.request.query_hash'][:array].is_a?(Array)

    env = create_env.merge('rack.request.form_hash' => {array: {'0' => 'is integer', '1' => 'is integer', '2' => 'is integer'}})
    env['REQUEST_METHOD'] = 'POST'
    Rack::JQueryParams.fix(env, :get)
    assert env['rack.request.form_hash'][:array].is_a?(Hash)
  end

end
