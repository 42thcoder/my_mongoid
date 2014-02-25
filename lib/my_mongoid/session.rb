require 'moped'
require "active_support/inflector"

module MyMongoid
  def self.session
    raise UnconfiguredDatabaseError unless MyMongoid.configuration.host && MyMongoid.configuration.database
    return @session if defined? @session
    @session = Moped::Session.new([ MyMongoid.configuration.host ])
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
      puts 'create'
      instance = self.new(attrs)
      instance.save
      instance
    end

    def instantiate(attrs)
      instance = self.new({})
      attrs.each_pair do |k, v|
        instance.attributes[k] = v
      end
      instance.instance_variable_set :@is_new, false
      instance
    end

    def find(query)
      if query.instance_of? String
        query = { _id: query }
      end
      result = self.collection.find(query).one
      raise RecordNotFoundError unless result
      instance = self.instantiate(result)
      instance
    end
  end
end
