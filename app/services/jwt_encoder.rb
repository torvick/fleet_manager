class JwtEncoder
  ALGORITHM = 'HS256'.freeze
  DEFAULT_EXP = 24.hours

  class << self
    def secret_key
      Rails.application.credentials.dig(:jwt, :secret) ||
        ENV['JWT_SECRET'] ||
        Rails.application.secret_key_base
    end

    def encode(payload, exp: DEFAULT_EXP.from_now)
      to_encode = payload.merge({ iat: Time.now.to_i, exp: exp.to_i })
      JWT.encode(to_encode, secret_key, ALGORITHM)
    end

    def decode(token)
      decoded, = JWT.decode(token, secret_key, true, { algorithm: ALGORITHM })
      decoded.with_indifferent_access
    end
  end
end
