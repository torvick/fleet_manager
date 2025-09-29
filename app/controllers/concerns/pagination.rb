module Pagination
  extend ActiveSupport::Concern
  include Pagy::Backend

  def paginate_json(scope)
    pagy, records = pagy(scope)
    [records, pagy_metadata(pagy)]
  end
end
