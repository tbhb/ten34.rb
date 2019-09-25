# frozen_string_literal: true

module Ten34
  module Errors
    class Base < StandardError; end

    class DatabaseNotFound < Base; end

    class KeyNotFound < Base; end
  end
end
