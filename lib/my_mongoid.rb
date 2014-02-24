require "my_mongoid/document"
require 'active_support/concern'

module MyMongoid

  def self.models
    @models ||= []
  end

  def self.register_model(klass)	
    # why self todo
    @models << klass unless models.include?(klass)
  end

end
