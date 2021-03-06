class User < ActiveRecord::Base
    has_many :user_books
    has_many :books, through: :user_books

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
    
    def self.proper_username?(username, session)
        username = username.strip # Strips leading a trailing whitespace
        user = User.find_by(username: username)
        
        if user then session[:flash] << error_list[:user_exists] end
        if username.length < 6 || username.match(/\s/) then session[:flash] << error_list[:wrong_username] end
    end

    def self.proper_password?(password, password_auth, session)
        session[:flash] << error_list[:no_match] if password != password_auth
        session[:flash] << error_list[:wrong_number_count] unless password.match(/^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$/)
    end

    def self.error_list
        {
            no_match: "The passwords you entered do not match.",
            wrong_number_count: "The password must be between 8 and 30 characters long and contain at least one letter and number.",
            user_exists: "The user by that name already exists. Please choose a different name.",
            wrong_username: "Please make sure the length of your username is between 6 and 30 characters long and it contains no spaces.",
            bad_credentials: "Username and/or password incorrect",
            no_user: "No such user",
            not_logged_in: "Please log in to continue",
            unauthorized: "You are not authorized to use this resource"
        }
    end
end