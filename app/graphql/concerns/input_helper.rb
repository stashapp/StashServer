module InputHelper
  def validate_input(input:, type:)
    input.to_h.stringify_keys.select { |x| x != 'id' && type.attribute_names.index(x) }
  end
end