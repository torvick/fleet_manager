class Vehicle < ApplicationRecord
  has_many :maintenance_services, dependent: :destroy

  enum :status, {
    active: 0,
    inactive: 1,
    in_maintenance: 2
  }, prefix: true

  validates :vin,   presence: true, uniqueness: { case_sensitive: false }
  validates :plate, presence: true, uniqueness: { case_sensitive: false }
  validates :brand, :model, presence: true
  validates :year,  presence: true, inclusion: { in: 1990..2050 }

  scope :search, lambda { |q|
    next all if q.blank?

    where(
      'LOWER(vin) LIKE :q OR LOWER(plate) LIKE :q OR LOWER(brand) LIKE :q OR LOWER(model) LIKE :q',
      q: "%#{q.downcase}%"
    )
  }

  scope :by_status, ->(st) { st.present? ? where(status: st) : all }
  scope :by_brand,  ->(b)  { b.present?  ? where('LOWER(brand) = ?', b.downcase) : all }
  scope :by_year,   ->(y)  { y.present?  ? where(year: y) : all }
end
