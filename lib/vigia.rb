# encoding: utf-8

require 'redsnow'
require 'rspec'
require 'rest_client'
require 'uri_template'

require_relative 'vigia/blueprint'
require_relative 'vigia/config'
require_relative 'vigia/example'
require_relative 'vigia/basic'
require_relative 'vigia/headers'
require_relative 'vigia/http_client/rest_client'
require_relative 'vigia/parameters'
require_relative 'vigia/rspec'
require_relative 'vigia/url'
require_relative 'vigia/version'

module Vigia
  class << self
    def config
      @config
    end
    def configure
      @config = Vigia::Config.new
      yield @config
      @config.validate!
    end
    def spec_folder
      File.join(__dir__, 'vigia', 'spec')
    end
    def rspec!
      Vigia::Rspec.new.run!
    end
  end
end
