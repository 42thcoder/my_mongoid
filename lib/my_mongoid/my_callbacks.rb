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
      attr_accessor :chain, :before_callbacks, :around_callbacks, :after_callbacks

      def initialize
        @chain = []
        @before_callbacks = @around_callbacks = @after_callbacks = []
      end

      def empty?
        @chain.empty?
      end

      def append(callback)
        @chain.push callback
      end

      def invoke(target, &block)
        _invoke(0, target, &block)
      end

      protected

      def _invoke(i, target, &block)
        if i >= @chain.length
          block.call
        else
          # TODO: dirty?
          @chain[i].invoke(target) if @chain[i].kind == :before
          if @chain[i].kind == :around
            @chain[i].invoke(target) do
              _invoke(i+1, target, &block)
            end
          else
            _invoke(i+1, target, &block)
          end
          @chain[i].invoke(target) if @chain[i].kind == :after
        end
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

      def invoke(target, &block)
        # TODO: String, Proc & Object Supporting
        target.send(filter, &block)
      end
    end

  end
end
