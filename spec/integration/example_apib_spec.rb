require 'spec_helper'
require 'support/integration_helper'

start_example_server
wait_until_ready

# Configure Vigia to run spec/example.apib
Vigia.configure do |config|
  config.host      = Vigia::ExampleApp.host
  config.apib_path = Vigia::ExampleTest.apib_path
  #config.custom_examples_paths = File.join(__dir__, '../', 'support', 'shared_examples', 'my_custom_examples')
  #config.add_custom_examples_on(:all, 'my custom examples')
  #config.add_custom_examples_on('Scenarios', 'scenarios resource examples')
  #config.add_custom_examples_on('Retrieve all Scenarios', 'scenarios get index action examples')
end

# Run Vigia within RSpec process
require File.join(Vigia.spec_folder, 'blueprint_basic_spec')
require File.join(Vigia.spec_folder, 'blueprint_examples_spec')
