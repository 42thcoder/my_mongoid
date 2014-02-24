require "my_mongoid/fields"
require "my_mongoid/session"
require "my_mongoid/attributes"
require 'active_support/concern'

module MyMongoid

  module Document
    extend ActiveSupport::Concern
    include Fields
    include Attributes

    included do
      MyMongoid.register_model(self)
    end

    def new_record?
      @is_new
    end

    def to_document
      @attributes
    end

    def save
      self.class.collection.insert(self.to_document)
      @is_new = false
      true
    end

    def initialize(attributes)
      raise ArgumentError, 'It is not a hash' unless attributes.is_a?(Hash)
      @is_new = true
      @attributes ||= {}
      # todo @attributes = attributes 会导致错误
      # adding new key in interation

      process_attributes(attributes)
    end

    module ClassMethods
      include Session
      def is_mongoid_model?
        true
      end
    end
  end

end
