require_relative '../helpers/helpers.rb'

class UsersController < ApplicationController
    # include Helpers

    get '/login' do 
        redirect to '/' if Helpers.is_logged_in?(session)

        erb :'users/login'
    end

    post '/login' do 
        clear_errors

        @user = User.find_by(username: params[:username])

        if @user && @user.password == params[:password]
            give_token
            redirect to '/'
        else
            session[:flash] << User.error_list[:bad_credentials]
            redirect to '/login'
        end
    end

    get '/logout' do 
        session.delete(:user_id)
        redirect to '/'
    end

    get '/signup' do 
        redirect to '/' if Helpers.is_logged_in?(session)

        erb :'users/signup'
    end

    post '/signup' do 
        username = params[:username]
        password = params[:password]
        
        User.proper_username?(username, session)
        User.proper_password?(password, params[:password_auth], session)
        
        if session[:flash].empty? 
            @user = User.new(username: username)
            @user.password = password
            @user.save!

            give_token
            redirect to '/'
        else
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

end