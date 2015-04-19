module Neo4j::ActiveNode
  module Property
    extend ActiveSupport::Concern
    include Neo4j::Shared::Property

    def initialize(attributes = {}, options = {})
      super(attributes, options)
      send_props(@relationship_props) if _persisted_obj && !@relationship_props.nil?
    end

    module ClassMethods
      # Extracts keys from attributes hash which are associations of the model
      # TODO: Validate separately that relationships are getting the right values?  Perhaps also store the values and persist relationships on save?
      def extract_association_attributes!(attributes)
        attributes.each_with_object({}) do |(key, value), result|
          result[key] = attributes.delete(key) if self.association?(key)
        end
      end
    end
  end
end
