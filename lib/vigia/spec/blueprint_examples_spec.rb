# encoding: utf-8

describe Vigia::Rspec do

  described_class.include_shared_folders

  described_class.apib.resource_groups.each do |resource_group|
    describe description_for(resource_group) do
      resource_group.resources.each do |resource|
        describe description_for(resource) do
          resource.actions.each do |action|
            describe description_for(action) do
              action.examples.each do |apib_example|
                runner_example  = Vigia::Example.new(
                                    resource: resource,
                                    action: action,
                                    apib_example: apib_example)

                if runner_example.skip?
                  include_examples 'skip example', runner_example
                else
                  include_examples 'apib example', runner_example
                end
              end
            end
          end
        end
      end
    end
  end
end
