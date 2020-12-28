class UsersController < ApplicationController

    register Sinatra::Flash

    get '/signup' do 
        @errors = []
        if session[:flash]
            @errors = session.delete(:flash).flatten
        end

        erb :'users/signup'
    end

    post '/signup' do 
        username = params[:username]
        password = params[:password]
        checked_username = proper_username?(username)
        checked_password = proper_password?(password)
        
        errors = []

        unless username == checked_username then errors << checked_username end
        unless password == checked_password then errors << checked_password end
        
        if errors.empty? 
            user = User.new(name: username)
            user.password = password
            user.save!
            session[:user_id] = user.id
            redirect to '/'
        else
            session[:flash] = errors
            redirect '/signup'
        end
    end

    private

    def proper_username?(username)
        username = username.strip # Strips leading a trailing whitespace
        user = User.find_by(name: username)
        
        user_exists_error = "The user by that name already exists. Please choose a different name."
        username_wrong_error = "Please make sure the length of your username is between 6 and 30 characters long and it contains no spaces."

        errors = []

        if user then errors << user_exists_error end
        if username.length < 6 || username.match(/\s/) then errors << username_wrong_error end

        return_value = errors.empty? ? username : errors
        return_value
    end

    def proper_password?(password)
        unless password.match(/^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$/)
            "The password must be between 8 and 30 characters long and contain at least one letter and number"
        else
            password
        end
    end

end