# frozen_string_literal: true

require 'active_support/core_ext/module/attribute_accessors'
require 'tty/logger'

require 'ten34/version'
require 'ten34/errors'

module Ten34
  def self.log_level=(val)
    @log_level = val
  end

  def self.log_level
    @log_level ||= :info
  end

  def self.logger
    @logger ||=
      begin
        TTY::Logger.new do |config|
          config.level = Ten34.log_level
        end
      end
  end
end
