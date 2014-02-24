require 'moped'

module MyMongoid
  def self.session
    raise UnconfiguredDatabaseError unless MyMongoid.configuration.host && MyMongoid.configuration.database
    @session ||= Moped::Session.new([ "localhost:27017" ])
  end
end
