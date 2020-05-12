# config/initializers/pusher.rb
require 'pusher'

Pusher.app_id = '992460'
Pusher.key = '6f4907a260e6ad2dab43'
Pusher.secret = '325ed6c63c0dd7cb4898'
Pusher.cluster = 'us2'
Pusher.logger = Rails.logger
Pusher.encrypted = true

# app/controllers/hello_world_controller.rb
#