require "my_mongoid/version"
require 'active_support/concern'

module MyMongoid
	DuplicateFieldError = 'There is already a field with same name'
	UnknownAttributeError = 'UnknownAttributeError'

	module Field
		extend ActiveSupport::Concern

		included do
			# alias :attributes= :process_attributes
		end

		def initialize(attributes)
		  process_attributes(attributes)
		end

		module ClassMethods
			def field(name)
				named = name.to_s
				@@fields ||= Hash.new

				raise DuplicateFieldError if @@fields[named]
				@@fields[named] = "a kind of Mongoid::Field"	#todo
				@@fields['_id'] = 0

				self.class_eval do

					define_method name do
						read_attribute(named)
					end

					define_method("#{named}=") do |value|
						write_attribute(named, value)
					end

					def process_attributes(attr)
						attr.each_pair do |key, val| 
							key_s = key.to_s
							raise UnknownAttributeError unless @@fields[key_s]
							public_send("#{key_s}=", val) 	
							# todo  can't add a new key into hash during iteration
						end
					end

					def attributes=(attr)
						process_attributes attr
					end

				end
			end

			def fields
				@@fields
			end

		end
	end
end
