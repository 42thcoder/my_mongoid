require "my_mongoid/version"
require 'active_support/concern'

module MyMongoid

	module Field
		extend ActiveSupport::Concern

		included do

		end

		module ClassMethods
			def field(name)
				self.class_eval do
					attr_accessor :public
				end
			end
		end
	end
end
