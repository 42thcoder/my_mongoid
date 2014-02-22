require "my_mongoid/version"
require "my_mongoid/field"
require 'active_support/concern'

module MyMongoid

	module Document
		extend ActiveSupport::Concern
		include Field

		@@models = []

		included do
			extend ClassMethods

			@@models << self

			self.class_eval do
				attr_accessor :attributes

				def read_attribute(key)
					@attributes[key]
				end

				def write_attribute(key, value)
					@attributes[key] = value
				end

				def new_record?
					true
				end
			end
		end

		def initialize(attributes)
			raise ArgumentError, 'It is not a hash' unless attributes.is_a?(Hash)
			@attributes = attributes

			MyMongoid.models ||= []
			super
		end

		def MyMongoid.models
			@@models
		end

		module ClassMethods
			def is_mongoid_model?
				true
			end
		end
	end

end
