require "my_mongoid/document"
require "my_mongoid/configuration"
require "my_mongoid/session"
require "my_mongoid/errors"
require 'active_support/concern'

module MyMongoid

  def self.models
    @models ||= []
  end

  def self.register_model(klass)
    # why self todo
    @models << klass unless models.include?(klass)
  end

  def self.configure
    block_given? ? yield(Configuration.instance) : Configuration.instance
  end

  def self.configuration
    Configuration.instance
  end

end
