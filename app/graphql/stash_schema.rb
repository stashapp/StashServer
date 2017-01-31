StashSchema = GraphQL::Schema.define do
  query QueryType

  resolve_type -> (obj, ctx) do
    case obj.class
    when Scene
      SceneType
    when Performer
      PerformerType
    else
      raise("Don't know how to get the GraphQL type of a #{obj.class.name} (#{obj.inspect})")
    end
  end

  object_from_id ->(id, ctx) do
    type_name, item_id = GraphQL::Schema::UniqueWithinType.decode(id)
    type_name.constantize.find(item_id)
  end

  id_from_object -> (object, type_definition, ctx) do
    GraphQL::Schema::UniqueWithinType.encode(type_definition.name, object.id)
  end
end
