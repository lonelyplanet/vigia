module Vigia
  class Basic

    attr_reader :action, :resource, :requests, :headers, :parameters

    def initialize(resource:, action:)
      @resource     = resource
      @action       = action
      @parameters   = Vigia::Parameters.new(resource, action)
      @headers      = Vigia::Headers.new(resource)
      @url          = Vigia::Url.new(resource.uri_template)
    end

    def perform_request(request: nil, parameter_values: {})
      options = {
        method:  action.method,
        url:     url(parameter_values),
        headers: headers(request)
      }
      options.merge!(payload: request.body) if !request.nil?
      http_client_request(options)
    end

    def url(parameter_values)
      @url.absolute_url @url.uri_template.expand(parameter_values)
    end

    private

    def http_client_request(http_options)
      Vigia.config.http_client_class.new(http_options).run!
    end

    def headers(request)
      collection = {}
      if !@resource.model.headers.collection.nil?
        @resource.model.headers.collection.each do |header|
          collection[header[:name]] = header[:value]
        end
      end
      if !request.nil?
        request.headers.collection.each do |header|
          collection[header[:name]] = header[:value]
        end
      end
      return collection
    end
  end
end
