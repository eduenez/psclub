source "https://rubygems.org"

gem "jekyll", "~> 4.3"

group :jekyll_plugins do
  gem "jekyll-feed",    "~> 0.17"
  gem "jekyll-sitemap", "~> 1.4"
  gem "jekyll-seo-tag", "~> 2.8"
end

gem "webrick", "~> 1.8"

# Extracted from the standard library in Ruby 3.4; Jekyll 4.3 still expects
# them to be present. Without these the build dies on `require "csv"`.
gem "csv"
gem "base64"
gem "bigdecimal"
gem "logger"
