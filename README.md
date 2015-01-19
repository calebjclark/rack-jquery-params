rack-jquery-params
===========

A Rack middleware that bridges the discrepancy between jQuery.param and how Rack parses nested params within query
strings and post bodies.

If you use jQuery's get, post, put, or ajax methods then jQuery.param is run on your data. The problem is that jQuery.param
turns this javascript object:

 ```
 {test: [{this_is_an_object_inside_an_array:'yes'}]}
 ```

into a query string that Rack cannot read correctly:

```
test[0][this_is_an_object_inside_an_array]=yes
```

Rack expects all arrays to be sent as empty brackets (i.e., "test[]"). It parses jQuery's "test[0]" as a hash, resulting
in the following params:

```ruby
{
    :test => {
        :0 => {
            :this_is_an_object_inside_an_array => 'yes'
        }
    }
}
```

This gem fixes the above params and converts it to:

```ruby
{
    :test => [
        {
            :this_is_an_object_inside_an_array => 'yes'
        }
    ]
}
```

## Setting Up JSONR

Install the gem:

```ruby
gem install rack-jquery-params
```

In your Gemfile:

```ruby
gem 'rack-jquery-params', :require => 'rack/jquery-params'
```

Activate by including it your config.ru file:

```ruby
use Rack::JQueryParams
run Sinatra::Application
```

## Options

By default the JQueryParams fix is applied to all http methods, however you can change this functionality by setting
the applies_to option with your chosen http method:

```ruby
use Rack::JQueryParams :applies_to => :get
```

 You can also set applies_to to be an array of http methods:

```ruby
use Rack::JQueryParams :applies_to => [:get, :put, :delete]
```
