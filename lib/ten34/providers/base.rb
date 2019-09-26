# frozen_string_literal: true

require 'ten34/logging'

module Ten34
  module Providers
    class Base
      include Ten34::Logging

      def initialize(name, opts = {})
        @name = name
        @opts = opts
      end

      def create_db(opts = {}); end

      def delete_db(opts = {}); end

      def del(key, opts = {}); end

      def get(key, opts = {}); end

      def put(key, value, opts = {}); end

      def keys(pattern, opts = {}); end

      protected

      attr_reader :name, :opts
    end
  end
end
