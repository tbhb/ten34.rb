# frozen_string_literal: true

require 'base64'

require 'google/cloud/dns'
require 'retriable'

require 'ten34/providers/base'

module Ten34
  module Providers
    class CloudDNS < Base
      def initialize(name, opts = {})
        super

        @project_id = opts[:google_project_id]

        logger.debug("Using Cloud DNS provider for database #{zone_name}")
      end

      def create_db(_opts = {})
        logger.debug("Creating database: #{zone_name}")
        zones = cloud_dns.zones
        if zones.any? { |z| z.name == zone_name }
          logger.debug("Zone already exists: #{zone_name}")
          return
        end
        zone = cloud_dns.create_zone(zone_name, "#{name}.")
      end

      def delete_db(_opts = {})
        logger.debug("Deleting database: #{zone_name}")
        zone.delete
      end

      def del(key, _opts = {})
        logger.debug("Deleting key: #{key}")

        zone.remove("#{key}.#{name}.", 'TXT')
      end

      def get(key, _opts = {})
        logger.debug("Getting value for key: #{key}")

        record = zone.records.find { |r| r.name == "#{key}.#{name}." }
        raise Ten34::Errors::KeyNotFound, key unless record

        puts record.data.first.delete_prefix('"').delete_suffix('"')
      end

      def put(key, value, opts = {})
        logger.debug("Setting value for key: #{key}")

        zone.replace("#{key}.#{name}.", 'TXT', 60, "\"#{value}\"")
      end

      def keys(pattern, _opts = {})
        logger.debug("Getting keys matching pattern: #{pattern}")

        all_keys = zone.records.select { |r| r.type == 'TXT' }.map(&:name).map { |k| k.delete_suffix(".#{name}.") }
        all_keys.grep(Regexp.new(pattern)).each { |k| puts k }
      end

      private

      attr_reader :project_id

      def zone
        @zone ||= cloud_dns.zone(zone_name)
      end

      def zone_name
        @zone_name ||= name.gsub(/\./, '-')
      end

      def cloud_dns
        @cloud_dns ||= Google::Cloud::Dns.new(project_id: project_id)
      end
    end
  end
end
