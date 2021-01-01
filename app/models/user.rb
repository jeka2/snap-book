class User < ActiveRecord::Base
    has_many :books
    has_many :authors, through: :books

    def set_password(password)
        binding.pry
        @password = BCrypt::Password.create(password)
        self.password = @password
    end
end