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
    def set(key, value)
      Ten34::Client.new(db).set(key, value)
    end

    desc 'keys', 'Gets keys matching the specified pattern'
    method_option :db, type: :string, aliases: '-d'
    def keys(pattern)
      Ten34::Client.new(db).keys(pattern)
    end

    private

    def db
      @db ||=
        begin
          db = ENV.fetch('TEN34_DB', options[:db])
          unless db
            puts 'Database must be specified with --db or TEN34_DB in environment'
            exit(1)
          end
          db
        end
    end
  end
end
