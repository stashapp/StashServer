# Call scopes directly from your URL params:
#
#     @products = Product.filter(params.slice(:status, :location, :starts_with))
module Filterable
  extend ActiveSupport::Concern

  module ClassMethods

    # Call the class methods with the same name as the keys in <tt>filtering_params</tt>
    # with their associated values. Most useful for calling named scopes from
    # URL params. Make sure you don't pass stuff directly from the web without
    # whitelisting only the params you care about first!
    def filter(params)
      params = params.stringify_keys
      results = self.where(nil) # create an anonymous scope
      params.each do |key, value|
        if value.present? || (value.is_a?(TrueClass) || value.is_a?(FalseClass)) # TODO: Added this boolean check, test this...
          value = value.split(',') if value.is_a? String
          results = results.public_send(key, value)
        end
      end
      results
    end
  end
end
