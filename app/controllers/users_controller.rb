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

        @user = User.find_by(username: params[:username])
        if @user && @user.password == params[:password]
            give_token
            redirect to '/'
        else
            add_error(User.error_list[:bad_credentials])
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
        
        User.proper_username?(username)
        User.proper_password?(password, params[:password_auth])
        
        if @flash.empty? 
            @user = User.new(username: params[:username])
            @user.password = params[:password]
            @user.save!

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

end