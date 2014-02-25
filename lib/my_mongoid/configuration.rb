require 'singleton'

module MyMongoid
  class Configuration
    include Singleton
    attr_accessor :host
    attr_accessor :database
  end
end
