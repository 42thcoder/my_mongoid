require 'moped'
require "active_support/inflector"

module MyMongoid
  def self.session
    raise UnconfiguredDatabaseError unless MyMongoid.configuration.host && MyMongoid.configuration.database
    @session ||= Moped::Session.new([ "localhost:27017" ])
    @session.use(MyMongoid::configuration.database)
    @session
  end
  module Session
    def collection_name
      self.name.tableize
    end

    def collection
      MyMongoid.session[collection_name]
    end

    def create(attrs)
      instance = self.new(attrs)
      instance.save
      instance
    end
  end
end
