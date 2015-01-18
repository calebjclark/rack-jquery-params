rack-jquery-params
===========

A Rack middleware for bridging the discrepancy between jQuery.param and how Rack parses nested queries. Using
jQuery.get/post/put/ajax/etc, will result in jQuery.param will be called on the data you pass. The final result is a
query string that turns {test: [{this_is_an_object_inside_an_array:'yes'}]} into the following query string:

```
test[0][this_is_an_object_inside_an_array]=yes
```

The problem is that Rack::Utils.parse_nested_query reads test[0] as a hash and outputs the following params:

```
{
    "test" => {
        "0" => {
            "this_is_an_object_inside_an_array" => "yes"
        }
    }
}
```

## Setting Up JSONR

Install the gem:

  gem install rack-jquery-params

In your Gemfile:

  gem 'rack-jquery-params', :require => 'rack/jquery-params'

You activate the functionality by including it your config.ru file:

 ```
 use Rack::JQueryParams
 run Sinatra::Application
 ```

