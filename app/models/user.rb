class User < ActiveRecord::Base
    has_many :books
    has_many :authors, through: :books

    def password
        @password ||= BCrypt::Password.new(password_hash)
    end

    def password=(new_password)
        @password = BCrypt::Password.create(new_password)
        self.password_hash = @password
    end

    def self.displayable_version(str)
        if str.match(/_/)
            transformed_key = str.split(/_/).map(&:capitalize).join(' ')
        else
            transformed_key = str.capitalize
        end
    end
end