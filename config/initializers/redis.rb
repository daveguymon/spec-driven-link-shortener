require "redis"

Rails.application.config.x.redis = Redis.new(
  url: ENV.fetch("REDIS_URL", "redis://localhost:6379/0"),
  timeout: 5
)
