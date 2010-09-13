module Neo4j::Mapping
  module RelationshipClassMethods
    def decl_relationships
      # :nodoc:
      self::DECL_RELATIONSHIPS
    end

    # Specifies a relationship between two node classes.
    # Generates assignment and accessor methods for the given relationship.
    #
    # ==== Example
    #
    #   class FolderNode
    #      include Ne4j::NodeMixin
    #      has_n(:files)
    #   end
    #
    #   folder = FolderNode.new
    #   folder.files << Neo4j::Node.new << Neo4j::Node.new
    #   folder.files.inject {...}
    #
    # ==== Returns
    #
    # Neo4j::Mapping::DeclRelationshipDsl
    #
    def has_n(rel_type, params = {})
      clazz = self
      module_eval(%Q{
                def #{rel_type}(&block)
                    dsl = #{clazz}.decl_relationships[:'#{rel_type.to_s}']
                    Neo4j::Mapping::HasN.new(self, dsl, &block)
                end}, __FILE__, __LINE__)

      module_eval(%Q{
                def #{rel_type}_rels
                    dsl = #{clazz}.decl_relationships[:'#{rel_type.to_s}']
                    Neo4j::Mapping::HasN.new(self, dsl).rels
      end}, __FILE__, __LINE__)

      decl_relationships[rel_type.to_sym] = Neo4j::Mapping::DeclRelationshipDsl.new(rel_type, params)
    end


    # Specifies a relationship between two node classes.
    # Generates assignment and accessor methods for the given relationship
    # Old relationship is deleted when a new relationship is assigned.
    #
    # ==== Example
    #
    #   class FileNode
    #      include Ne4j::NodeMixin
    #      has_one(:folder)
    #   end
    #
    #   file = FileNode.new
    #   file.folder = Neo4j::Node.new
    #   file.folder # => the node above
    #   file.folder_rel # => the relationship object between those nodes
    #
    # ==== Returns
    #
    # Neo4j::Relationships::DeclRelationshipDsl
    #
    def has_one(rel_type, params = {})
      clazz = self


      module_eval(%Q{def #{rel_type}=(value)
                    dsl = #{clazz}.decl_relationships[:'#{rel_type.to_s}']
                    r = Neo4j::Mapping::HasN.new(self, dsl)
                    r.rels.each {|n| n.del} # delete previous relationships, only one can exist
                    r << value
                    r
                end}, __FILE__, __LINE__)

      module_eval(%Q{def #{rel_type}
                    dsl = #{clazz}.decl_relationships[:'#{rel_type.to_s}']
                    r = Neo4j::Mapping::HasN.new(self, dsl)
                    [*r][0]
                end}, __FILE__, __LINE__)

      module_eval(%Q{
                def #{rel_type}_rel
                    dsl = #{clazz}.decl_relationships[:'#{rel_type.to_s}']
                    r = Neo4j::Mapping::HasN.new(self, dsl).rels
                    [*r][0]
      end}, __FILE__, __LINE__)

      decl_relationships[rel_type.to_sym] = Neo4j::Mapping::DeclRelationshipDsl.new(rel_type, params)
    end

  end
end