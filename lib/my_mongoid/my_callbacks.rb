require 'active_support/core_ext'

module MyMongoid
  module MyCallbacks

    def self.included(base)
      base.extend ClassMethods
    end

    # TODO: I know it could be done by ActiveSupport::Concern. But later?
    module ClassMethods
      def define_callbacks(name)
        class_attribute "_#{name}_callbacks"
        send("_#{name}_callbacks=", CallbackChain.new)
      end

      def set_callback(name, kind, filter)
        send("_#{name}_callbacks").append(Callback.new(filter, kind))
      end

    end

    def run_callbacks(name)
      self.class.send("_#{name}_callbacks").invoke(self) do
        yield
      end
    end

    # fancy Array, store all callbacks for one spec
    class CallbackChain
      attr_accessor :chain

      def initialize
        @chain = []
      end

      def empty?
        @chain.empty?
      end

      def append(callback)
        @chain.push callback
      end

      def invoke(target)
        @chain.each do |callback|
          callback.invoke(target)
        end
        yield
      end
    end

    class Callback
      attr_accessor :kind, :filter

      # @param [Symbol] filter The callback method name.
      # @param [Symbol] kind The kind of callback
      def initialize(filter, kind)
        @filter = filter
        @kind = kind
      end

      def invoke(target)
        target.send(filter)
      end
    end

  end
end
