class GraphqlChannel < ApplicationCable::Channel
  def subscribed
    @subscription_ids = []
  end

  def execute(data)
    query = data["query"]
    variables = ensure_hash(data["variables"])
    operation_name = data["operationName"]
    context = {
      # Make sure the channel is in the context
      channel: self
    }

    result = StashApiSchema.execute(query, variables: variables, context: context, operation_name: operation_name)

    payload = {
      result: result.subscription? ? nil : result.to_h,
      more: result.subscription?
    }

    # Track the subscription here so we can remove it on unsubscribe.
    if result.context[:subscription_id]
      @subscription_ids << context[:subscription_id]
    end

    transmit(payload)
  end

  def unsubscribed
    @subscription_ids.each { |sid|
      StashApiSchema.subscriptions.delete_subscription(sid)
    }
  end

  private

    def ensure_hash(query_variables)
      if query_variables.blank?
        {}
      elsif query_variables.is_a?(String)
        JSON.parse(query_variables)
      else
        query_variables
      end
    end
end
