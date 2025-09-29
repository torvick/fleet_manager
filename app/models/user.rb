class User < ApplicationRecord
  has_secure_password

  before_validation { self.email = email.to_s.strip.downcase }

  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :password, length: { minimum: 8 }, if: -> { password.present? }
  validates :role, presence: true, inclusion: { in: %w[admin manager agent] }
end
