class Functions::FindRecords < GraphQL::Function
  description "Reusable find"

  SortDirectionEnum = GraphQL::EnumType.define do
    name 'SortDirectionEnum'
    description 'Valid sort directions'

    value 'ASC', 'Ascending order', value: 'asc'
    value 'DESC', 'Descending order', value: 'desc'
  end

  FindFilterType = GraphQL::InputObjectType.define do
    name 'FindFilterType'

    argument :q, types.String, default_value: nil
    argument :page, types.Int, default_value: 1
    argument :per_page, types.Int, default_value: 25, prepare: ->(limit, ctx) { [limit, 120].min }
    argument :sort, types.String, default_value: nil
    argument :direction, SortDirectionEnum, default_value: 'desc'
  end

  argument :filter, FindFilterType

  def query(args)
    return nil if args[:filter].nil?
    return args[:filter][:q]
  end
end
