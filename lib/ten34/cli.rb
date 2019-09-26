# frozen_string_literal: true

require 'thor'

require 'ten34/client'

module Ten34
  class CLI < Thor
    def initialize(*args)
      super
    ensure
      self.options ||= {}
      Ten34.log_level = :debug if options['verbose']
    end

    check_unknown_options!

    class_option :verbose, type: :boolean, desc: 'Print verbose output', aliases: '-V'

    desc 'create-db', 'Creates a database'
    def create_db(uri)
      Ten34::Client.new(uri).create_db
    end

    desc 'delete-db', 'Deletes a database'
    def delete_db(uri)
      Ten34::Client.new(uri).delete_db
    end

    desc 'del', 'Deletes the specified key'
    method_option :db, type: :string, aliases: '-d'
    def del(key)
      Ten34::Client.new(db).del(key)
    end

    desc 'get', 'Gets the value of the specified key'
    method_option :db, type: :string, aliases: '-d'
    def get(key)
      Ten34::Client.new(db).get(key)
    end

    desc 'set', 'Sets the value of the specified key'
    method_option :db, type: :string, aliases: '-d'
    method_option :encrypt, type: :boolean, default: false, aliases: '-e'
    method_option :kms_key_id, type: :string
    def set(key, value)
      if options[:encrypt] && kms_key_id.nil?
        logger.fatal 'KMS key ID must be specified with --kms-key-id or TEN34_KMS_KEY_ID when encrypting'
        exit(1)
      end
      Ten34::Client.new(db).set(key, value, options.merge(kms_key_id: kms_key_id))
    end

    desc 'keys', 'Gets keys matching the specified pattern'
    method_option :db, type: :string, aliases: '-d'
    def keys(pattern)
      Ten34::Client.new(db).keys(pattern)
    end

    private

    include Logging

    def db
      @db ||=
        begin
          db = ENV.fetch('TEN34_DB', options[:db])
          unless db
            logger.fatal 'Database must be specified with --db or TEN34_DB in environment'
            exit(1)
          end
          db
        end
    end

    def kms_key_id
      @kms_key_id ||= ENV['TEN34_KMS_KEY_ID'] || options[:kms_key_id]
    end
  end
end
