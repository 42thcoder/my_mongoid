require 'active_support/concern'

module MyMongoid
	DuplicateFieldError = 'There is already a field with same name'
	UnknownAttributeError = 'UnknownAttributeError'

	class Field
		attr_accessor :name, :options

		def initialize(name, options = {})
			@name = name
			@options = options
		end
	end

	module Fields
		extend ActiveSupport::Concern

		included do
			field :_id, :as => :id
		end

		module ClassMethods

			def field(name, options = {})
				named = name.to_s
				@fields ||= Hash.new

				raise DuplicateFieldError if @fields[named]

				define_method name do
					read_attribute(named)
				end

				define_method("#{named}=") do |value|
					write_attribute(named, value)
				end

				field = Field.new(named, options)
				@fields[named] = field

				alias_method "#{options[:as]}=", "#{named}=" if options[:as]

				def fields
					@fields
				end

			end
		end
	end
end
