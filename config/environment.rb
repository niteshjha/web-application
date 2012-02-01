# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Webapp::Application.initialize!


# Using YAML to set application-wide variables - Railscast #85
Gutenberg = YAML.load_file("#{Dir.pwd}/config/gutenberg.yml")[Rails.env]
