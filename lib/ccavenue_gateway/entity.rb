module CcavenueGateway
  class Entity
    attr_accessor :attributes

    def initialize(attributes)
      @attributes = attributes
      # create_attribute_accessors
    end

   # Define dynamic attribute accessors using method_missing
    def method_missing(name, *args)
      attribute_name = name.to_s || name.to_sym 
      if attributes.key?(attribute_name)
        attributes[attribute_name]
      else
        super
      end
    end

    def respond_to_missing?(method_name, include_private = false)
      attributes.key?(method_name.to_sym || method_name.to_s) || super
    end

    # Public: Convert the Entity object to JSON
    # Returns the JSON representation of the Entity (as a string)
    def to_json(*args)
      @attributes.to_json(*args)
    end

  end
end