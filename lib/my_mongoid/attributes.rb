module MyMongoid

  module Attributes

    attr_accessor :attributes

    def process_attributes(attr)
      attr.each do |key, val|
        key_s = key.to_s
        raise UnknownAttributeError unless self.class.fields[key_s]
        # todo 如何调用类方法
        send("#{key_s}=", val)
      end
    end

    alias :attributes= :process_attributes

    def read_attribute(key)
      @attributes[key]
    end

    def write_attribute(key, value)
      @attributes[key] = value
    end

  end

end
