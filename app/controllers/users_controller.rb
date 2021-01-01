require_relative '../helpers/helpers.rb'

class UsersController < ApplicationController
    include Helpers

    get '/login' do 
        redirect to '/' if is_logged_in?(session)
        clear_errors
        display_flash

        erb :'users/login'
    end

    post '/login' do 
        clear_errors

        @user = User.find_by(name: params[:username])
        if @user && @user.password == params[:password]
            give_token
        else
            add_error(error_list[:bad_credentials])
            set_flash
            redirect to '/login'
        end
    end

    get '/logout' do 
        session.delete(:user_id)
        redirect to '/'
    end

    get '/signup' do 
        redirect to '/' if is_logged_in?(session)

        clear_errors
        display_flash

        erb :'users/signup'
    end

    post '/signup' do 
        clear_errors

        username = params[:username]
        password = params[:password]
        
        proper_username?(username)
        proper_password?(password, params[:password_auth])
        
        if @flash.empty? 
            @user = User.new(name: username)
            @user.set_password(password)
            @user.save
            give_token
            redirect to '/'
        else
            set_flash
            redirect '/signup'
        end
    end

    get '/users/:username' do 
        @user = User.find_by(username: params[:username])
        erb :'users/profile'
    end

private

    def give_token
        session[:user_id] = @user.id
    end

    def add_error(err)
        @flash << err
    end

    def clear_errors
        @flash = []
    end

    def set_flash
        session[:flash] = @flash
    end

    def display_flash
        if session[:flash]
            add_error(session.delete(:flash))
        end
    end

    def proper_username?(username)
        username = username.strip # Strips leading a trailing whitespace
        user = User.find_by(name: username)
        
        if user then add_error(error_list[:user_exists]) end
        if username.length < 6 || username.match(/\s/) then add_error(error_list[:wrong_username]) end
    end

    def proper_password?(password, password_auth)
        add_error(error_list[:no_match]) if password != password_auth
        add_error(error_list[:wrong_number_count]) unless password.match(/^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$/)
    end

    def error_list
        {
            no_match: "The passwords you entered do not match.",
            wrong_number_count: "The password must be between 8 and 30 characters long and contain at least one letter and number.",
            user_exists: "The user by that name already exists. Please choose a different name.",
            wrong_username: "Please make sure the length of your username is between 6 and 30 characters long and it contains no spaces.",
            bad_credentials: "Username and/or password incorrect"
        }
    end

end