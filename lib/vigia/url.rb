require 'uri'

module Vigia
  class Url

    attr_reader :uri_template

    # ApiBluprint uses RFC6570 in all its resource's uri_templates
    # https://github.com/apiaryio/api-blueprint/blob/master/API%20Blueprint%20Specification.md#1-uri-templates
    def initialize(apib_uri_template)
      @uri_template = ::URITemplate.new(:rfc6570, apib_uri_template)
    end

    def expand(parameters)
      validate(parameters) # if Vigia.config.validate_url_parameters?

      absolute_url uri_template.expand(parameters.to_hash)
    end

    def absolute_url path
      URI.join(host, path).to_s
    end

    def validate(parameters)
      return if required_template_parameters.empty?

      missing_parameters = required_template_parameters - valid_parameters(parameters)

      raise("Uri template #{ @uri_template } needs parameter/s #{ missing_parameters.join(',') }") unless missing_parameters.empty?
    end

    def host
      Vigia.config.host
    end

    private

    def valid_parameters(parameters)
      parameters.to_hash.delete_if{|_,v| v.nil? || v.empty? }.keys
    end

    def required_template_parameters
      uri_template.tokens.select{
        |token| token.is_a?(URITemplate::RFC6570::Expression::Basic)
      }.map(&:variables).flatten
    end
  end
end
