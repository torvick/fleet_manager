class User < ApplicationRecord
  has_secure_password

  enum :role, {
    viewer: 0,
    manager: 1,
    admin: 2
  }, prefix: true

  before_validation { self.email = email.to_s.strip.downcase }

  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :password, length: { minimum: 8 }, if: -> { password.present? }
  validates :role, presence: true
end
