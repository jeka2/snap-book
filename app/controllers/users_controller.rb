class UsersController < ApplicationController

    get '/login' do 
        clear_errors
        
        erb :'users/login'
    end

    post '/login' do 
        clear_errors

        @user = User.find_by(username: params[:username])
        if @user.password == params[:password]
            give_token
        else
            
        end
    end

    get '/signup' do 
        clear_errors

        if session[:flash]
            add_error(session.delete(:flash))
        end

        erb :'users/signup'
    end

    post '/signup' do 
        clear_errors

        username = params[:username]
        password = params[:password]
        
        proper_username?(username)
        proper_password?(password)
        
        if @errors.empty? 
            @user = User.new(name: username)
            @user.password = password
            @user.save!
            give_token
            redirect to '/'
        else
            session[:flash] = @errors
            redirect '/signup'
        end
    end

private

    def give_token
        session[:user_id] = @user.id
    end

    def add_error(err)
        @errors << err
    end

    def clear_errors
        @errors = []
    end

    def proper_username?(username)
        username = username.strip # Strips leading a trailing whitespace
        user = User.find_by(name: username)
        
        user_exists_error = "The user by that name already exists. Please choose a different name."
        username_wrong_error = "Please make sure the length of your username is between 6 and 30 characters long and it contains no spaces."
        if user then add_error(user_exists_error) end
        if username.length < 6 || username.match(/\s/) then add_error(username_wrong_error) end

    end

    def proper_password?(password)
        unless password.match(/^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$/)
            add_error("The password must be between 8 and 30 characters long and contain at least one letter and number")
        end
    end

end