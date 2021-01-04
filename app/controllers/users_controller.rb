require_relative '../helpers/helpers.rb'

class UsersController < ApplicationController
    include Helpers

    get '/login' do 
        redirect to '/' if Helpers.is_logged_in?(session)

        clear_errors
        display_flash

        erb :'users/login'
    end

    post '/login' do 
        clear_errors

        @user = User.find_by(username: params[:username])

        if @user && @user.password == params[:password]
            give_token
            redirect to '/'
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
        redirect to '/' if Helpers.is_logged_in?(session)

        clear_errors
        display_flash

        erb :'users/signup'
    end

    post '/signup' do 
        clear_errors

        username = params[:username]
        password = params[:password]
        
        authenticate_username(username)
        authenticate_password(password, params[:password_auth])
        
        if @flash.empty? 
            @user = User.new(username: username)
            @user.password = password
            @user.save!

            give_token
            redirect to '/'
        else
            set_flash
            redirect '/signup'
        end
    end

    get '/users/me' do 
        redirect to '/login' unless Helpers.is_logged_in?(session)

        user = User.find(session[:user_id])
        redirect to "/users/#{user.username}"
    end

    get '/users/:username' do 
        @user = User.find_by(username: params[:username])
        if @user
            # Compacts all relevant user info for display
            @user_info = @user.attributes.except('id', 'username', 'password_hash', 'image').compact

            erb :'users/profile'
        else
            status 404
            erb :'users/404'
        end
    end

    get '/users/:username/edit' do 
        @user = User.find_by(username: params[:username])
        
        unless @user.id == Helpers.current_user(session)
            status 403
            "Permission Denied"
        else
            @user_info = @user.attributes.except('id', 'username', 'password_hash', 'image')

            erb :'users/edit'
        end
    end

    patch '/users/:username/edit' do 
        @user = User.find_by(username: params[:username])
        params.each do |k, v|
            if @user.respond_to?(k)
                if @user.column_for_attribute(k).type == :integer
                    @user[k] = v.to_i
                elsif @user.column_for_attribute(k).type == :string
                    @user[k] = v.strip
                end
            end
        end
        @user.save!

        redirect to "/users/#{params[:username]}"
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

    def authenticate_username(username)
        username = username.strip # Strips leading a trailing whitespace
        user = User.find_by(username: username)
        
        if user then add_error(error_list[:user_exists]) end
        if username.length < 6 || username.match(/\s/) then add_error(error_list[:wrong_username]) end
    end

    def authenticate_password(password, password_auth)
        add_error(error_list[:no_match]) unless password == password_auth
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