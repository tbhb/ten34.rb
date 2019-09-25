require 'aws-sdk'

require 'ten34/providers/base'

module Ten34
  module Providers
    class Route53 < Base
      def initialize(name, opts = {})
        super

        logger.debug("Using Route53 provider for database #{name}")
      end

      def create_db(opts = {})
        logger.debug("Creating database: #{name}")

        resp = route53.list_hosted_zones_by_name
        hosted_zone_id = resp.hosted_zones.find { |h| h.name == "#{name}." }
        if hosted_zone_id
          logger.debug "Found hosted zone with ID #{hosted_zone_id} for database #{name}"
          return
        end

        ref = Time.now.to_i.to_s
        resp = route53.create_hosted_zone(
          name: name,
          caller_reference: ref
        )

        # TODO: Poll route53.get_change for creation status
      end

      def delete_db(opts = {})
        logger.debug("Deleting database: #{name}")

        resp = route53.list_hosted_zones_by_name
        hosted_zone = resp.hosted_zones.find { |h| h.name == "#{name}." }
        hosted_zone_id = hosted_zone.id if hosted_zone
        if hosted_zone_id
          logger.debug "Found hosted zone with ID #{hosted_zone_id} for database #{name}"
        end

        # TODO: Delete all resource record sets except for default SOA and NS

        resp = route53.delete_hosted_zone(id: hosted_zone_id)

        # TODO: Poll route53.get_change for deletion status
      end

      def del(key, opts = {})
        logger.debug("Deleting key: #{key}")

        resp = route53.list_hosted_zones_by_name
        hosted_zone = resp.hosted_zones.find { |h| h.name == "#{name}." }
        hosted_zone_id = hosted_zone.id if hosted_zone
        if hosted_zone_id
          logger.debug "Found hosted zone with ID #{hosted_zone_id} for database #{name}"
        else
          logger.fatal "Database not found: #{name}"
          raise Ten34::Errors::DatabaseNotFound, name
        end

        resp = route53.list_resource_record_sets(
          hosted_zone_id: hosted_zone_id,
          start_record_name: "#{key}.#{name}.",
          start_record_type: 'TXT',
          max_items: 1
        )

        raise(Ten34::Errors::KeyNotFound, key) if resp.resource_record_sets.empty?

        resource_record_set = resp.resource_record_sets.first

        resp = route53.change_resource_record_sets(
          change_batch: {
            changes: [
              action: 'DELETE',
              resource_record_set: {
                name: resource_record_set.name,
                resource_records: resource_record_set.resource_records,
                ttl: resource_record_set.ttl,
                type: 'TXT'
              }
            ],
            comment: "Delete key: #{key}"
          },
          hosted_zone_id: hosted_zone_id
        )

        # TODO: Poll route53.get_change for change status
      end

      def get(key, opts = {})
        logger.debug("Getting value for key: #{key}")

        resp = route53.list_hosted_zones_by_name
        hosted_zone = resp.hosted_zones.find { |h| h.name == "#{name}." }
        hosted_zone_id = hosted_zone.id if hosted_zone
        if hosted_zone_id
          logger.debug "Found hosted zone with ID #{hosted_zone_id} for database #{name}"
        else
          logger.fatal "Database not found: #{name}"
          raise Ten34::Errors::DatabaseNotFound, name
        end

        resp = route53.list_resource_record_sets(
          hosted_zone_id: hosted_zone_id,
          start_record_name: "#{key}.#{name}.",
          start_record_type: 'TXT',
          max_items: 1
        )

        raise(Ten34::Errors::KeyNotFound, key) if resp.resource_record_sets.empty?

        puts resp.resource_record_sets.first.resource_records.first.value.delete_prefix('"').delete_suffix('"')
      end

      def set(key, value, opts = {})
        logger.debug("Setting value for key: #{key}")

        resp = route53.list_hosted_zones_by_name
        hosted_zone = resp.hosted_zones.find { |h| h.name == "#{name}." }
        hosted_zone_id = hosted_zone.id if hosted_zone
        if hosted_zone_id
          logger.debug "Found hosted zone with ID #{hosted_zone_id} for database #{name}"
        else
          logger.fatal "Database not found: #{name}"
          raise Ten34::Errors::DatabaseNotFound, name
        end

        resp = route53.change_resource_record_sets(
          change_batch: {
            changes: [
              {
                action: 'UPSERT',
                resource_record_set: {
                  name: "#{key}.#{name}.",
                  resource_records: [
                    {
                      value: "\"#{value}\""
                    }
                  ],
                  ttl: 60,
                  type: 'TXT'
                }
              }
            ],
            comment: "Set #{key} to \"#{value}\""
          },
          hosted_zone_id: hosted_zone_id
        )

        # TODO: Poll route53.get_change for change status
      end

      private

      def route53
        @route53 ||= Aws::Route53::Client.new
      end
    end
  end
end