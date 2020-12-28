class User < ActiveRecord::Base
    has_many :books
    has_many :authors, through: :books

    def password=(password)
        @password = BCrypt::Password.create(password)
        self.password = @password
    end
end