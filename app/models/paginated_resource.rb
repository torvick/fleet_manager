class PaginatedResource < ActiveModelSerializers::Model
  attributes :collection, :meta
end
