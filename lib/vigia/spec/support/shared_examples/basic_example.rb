
def response_headers(response)
  headers = {}
  return headers if response.headers.collection.nil?

  response.headers.collection.each do |header|
    # Specific normalisation to RestClient
    # If using an alternate 'client' to query the API, possibly would need to change
    normalize_header_name = header[:name].gsub('-', '_').downcase.to_sym
    headers[normalize_header_name] = header[:value]
  end
  headers
end

def test_blueprint_action(runner, transaction, parameters)
  request = transaction.requests.first
  response = transaction.responses.first

  it 'returns the expected HTTP code' do
    result = runner.perform_request(request: request,
                                    parameter_values: parameters)
    expect(result[:code]).to eql(response.name.to_i)
  end

  it 'returns the expected HTTP headers' do
    result = runner.perform_request(request: request,
                                    parameter_values: parameters)
    expect(result[:headers]).to include(response_headers(response))
  end

  it 'returns the expected HTTP body' do
    # We may need to abort this test if the response template isn't included
    result = runner.perform_request(request: request,
                                    parameter_values: parameters)
    expect(result[:body]).to eql(response.body)
  end
end

shared_examples 'basic example' do |runner_basic|
  context description_for(runner_basic.action) do
    runner_basic.action.examples.each_with_index do |transaction_example, i|
      context "when testing transaction #{i}" do
        # separate the parameters into required and optional
        # and then loop through the optional performing each request with the optional parameter
        # parameter
        # For some reason redsnow parses the 'use' attribute as undefined, optional, required
        # despite the blueprint spec stating that required is the default
        parameters = {:required => {}, :optional => {}}
        runner_basic.action.parameters.collection.each do |parameter|
          value = parameter.example_value or parameter.default_value
          if parameter.use == :optional
            parameters[:optional][parameter.name] = value
          else
            parameters[:required][parameter.name] = value
          end
        end

        it 'has at least one defined response' do
          expect(transaction_example.responses.count).to be > 0
        end

        it "has default or example values for all of the parameters" do
          runner_basic.action.parameters.collection.each do |parameter|
            value = parameter.example_value or parameter.default_value
            expect(value).to_not be_nil
          end
        end

        context 'using only required parameters' do
          test_blueprint_action(runner_basic, transaction_example, parameters[:required])
        end

        parameters[:optional].each do |name, value|
          context "using optional parameter #{name}" do
            parameter_values = parameters[:required].dup
            parameter_values[name] = value
            test_blueprint_action(runner_basic, transaction_example, parameter_values)
          end
        end
      end
    end
  end
end
