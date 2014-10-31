# encoding: utf-8

describe Vigia::Rspec do

  described_class.include_shared_folders

  described_class.apib.resource_groups.each do |resource_group|
    describe description_for(resource_group) do
      resource_group.resources.each do |resource|
        describe description_for(resource) do
          resource.actions.each do |action|
            runner_basic = Vigia::Basic.new(
                             resource: resource,
                             action: action)
            include_examples 'basic example', runner_basic
          end
        end
      end
    end
  end
end
