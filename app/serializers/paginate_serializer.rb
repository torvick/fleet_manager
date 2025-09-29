class PaginateSerializer < ApplicationSerializer
  attributes :data, :meta

  def data
    coll = object.collection || []
    ser  = item_serializer_for(coll)
    ActiveModelSerializers::SerializableResource.new(
      coll,
      each_serializer: ser,
      adapter: :attributes,
      params: instance_options[:params]
    ).as_json
  end

  def meta
    object.meta || {}
  end

  private

  def item_serializer_for(coll)
    instance_options[:each_custom_serializer] ||
      instance_options[:each_serializer] ||
      (coll.respond_to?(:first) && ActiveModel::Serializer.serializer_for(coll.first)) ||
      (raise ArgumentError, 'each_serializer is required')
  end
end
