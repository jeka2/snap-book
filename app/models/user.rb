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
    
    def self.proper_username?(username)
        username = username.strip # Strips leading a trailing whitespace
        user = User.find_by(username: username)
        
        if user then add_error(error_list[:user_exists]) end
        if username.length < 6 || username.match(/\s/) then add_error(error_list[:wrong_username]) end
    end

    def self.proper_password?(password, password_auth)
        add_error(error_list[:no_match]) if password != password_auth
        add_error(error_list[:wrong_number_count]) unless password.match(/^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$/)
    end

    def self.error_list
        {
            no_match: "The passwords you entered do not match.",
            wrong_number_count: "The password must be between 8 and 30 characters long and contain at least one letter and number.",
            user_exists: "The user by that name already exists. Please choose a different name.",
            wrong_username: "Please make sure the length of your username is between 6 and 30 characters long and it contains no spaces.",
            bad_credentials: "Username and/or password incorrect"
        }
    end
end