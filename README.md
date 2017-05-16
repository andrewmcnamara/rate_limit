# Rate Limiting

This rails application demonstrates rate limiting of requests on a controller.

As the requirement was to limit requests to a controller, rate limiting has been implemented using a ```before_action``` on the controller.
This method will record the request attempt, and determine if the request can proceed or should be blocked.

This implementation stores each request attempt in Redis with an expiration of 1 hour. By using Redis with key expiration, 
limiting requests to a set amount just requires counting requests for an ip address. 

## Installation
Install Redis
```
brew install redis
```

Install Gems
```
bundle install
```

## Running 
```
bundle exec rails s
```

## Testing
 ```
 bundle exec rspec 
 ```

