require "my_mongoid/fields"
require "my_mongoid/session"
require "my_mongoid/attributes"
require "my_mongoid/callbacks"
require 'active_support/concern'
require 'active_model'

module MyMongoid

  module Document
    extend ActiveSupport::Concern
    include Fields
    include Attributes
    include Callbacks

    included do
      MyMongoid.register_model(self)
    end

    def new_record?
      @is_new
    end

    def changed?
      self.changed_attributes.keys.size > 0
    end

    def changed_attributes
      @changed_attributes ||= {}
    end

    def atomic_updates
      if !self.new_record? && self.changed?
        set = {}
        set["$set"] = {}
        self.changed_attributes.each_pair do |k, v|
          set["$set"][k] = self.read_attribute(k)
        end
        set
      else
        {}
      end
    end

    def to_document
      @attributes
    end

    def save
      run_callbacks(:save) do
        return true unless self.changed?
        if @is_new
          self.class.collection.insert(self.to_document)
          @is_new = false
        else
          self.class.collection.find({"_id" => self._id}).update(self.atomic_updates)
        end
        @changed_attributes = {}
        true
      end
    end

    def deleted?
      @deleted ||= false
    end

    def delete
      self.class.collection.find({"_id" => self._id}).remove
      @deleted = true
    end

    def update_document
      self.save
    end

    def update_attributes(attributes)
      process_attributes(attributes)
      self.update_document
    end

    def initialize(attributes)
      raise ArgumentError, 'It is not a hash' unless attributes.is_a?(Hash)
      @is_new = true
      @attributes ||= {}

      unless attributes.key?('id') or attributes.key?('_id')
        self._id = BSON::ObjectId.new
      end
      @changed_attributes = {}
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
