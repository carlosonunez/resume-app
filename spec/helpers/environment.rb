# frozen_string_literal: true

require 'singleton'

class MockEnv
  class << self
    include Singleton

    def table
      @table ||= {}
    end

    def mock!(key, value)
      return nil if table.key?(key)
      table[key] = ENV[key]
      ENV[key] = value
    end

    def unmock!(key)
      ENV[key] = table.delete(key)
    end

    def unmock_all!
      table.each_key do |key|
        unmock!(key)
      end
    end

    def list_mocks
      puts table
    end
  end
end
