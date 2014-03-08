module MyMongoid
  module Callbacks
    extend ActiveSupport::Concern

    included do
      extend ActiveModel::Callbacks
      define_model_callbacks :delete, :save, :create, :update
      define_model_callbacks :find, :initialize, :only => :after
    end
  end
end
