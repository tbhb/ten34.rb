# frozen_string_literal: true

require 'uri'

require 'active_support/core_ext/string/inflections'

require 'ten34/logging'

ActiveSupport::Inflector.inflections(:en) do |inflect|
  inflect.acronym 'DNS'
end

module Ten34
  class Client
    include Ten34::Logging

    def initialize(uri, opts = {})
      @parsed_uri = URI.parse(uri)
      @name = parsed_uri.host
      @opts = opts
      @provider = build_provider
    end

    def create_db(opts = {})
      provider.create_db(opts)
    end

    def delete_db(opts = {})
      provider.delete_db(opts)
    end

    def del(key, opts = {})
      provider.del(key, opts)
    end

    def get(key, opts = {})
      provider.get(key, opts)
    end

    def put(key, value, opts = {})
      provider.put(key, value, opts)
    end

    def keys(pattern, opts = {})
      provider.keys(pattern, opts)
    end

    private

    attr_reader :opts, :parsed_uri, :name, :provider

    def build_provider
      provider_name = parsed_uri.scheme.underscore.camelize
      logger.debug "Building provider for #{provider_name} and database #{name}"
      require "ten34/providers/#{parsed_uri.scheme.underscore}"
      Ten34::Providers.const_get(provider_name).new(name, opts)
    end
  end
end
