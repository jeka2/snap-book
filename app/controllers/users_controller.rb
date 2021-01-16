require_relative '../helpers/helpers.rb'

class UsersController < ApplicationController
    # include Helpers

    get '/login' do 
        redirect to '/' if Helpers.is_logged_in?(session)

        erb :'users/login'
    end

    post '/login' do 
        @user = User.find_by(username: params[:username])

        if @user && @user.password == params[:password]
            give_token
            redirect to '/'
        else
            Helpers.set_flash(session, User.error_list[:bad_credentials])
            redirect to '/login'
        end
    end

    get '/logout' do 
        redirect to '/' unless Helpers.is_logged_in?(session)

        remove_token
        
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
        @books = @user.books if @user
        
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
        
        Helpers.set_flash(session, User.error_list[:no_user], true) unless @user
        Helpers.set_flash(session, User.error_list[:unauthorized], true) if @user && (@user.id != Helpers.current_user(session))

        unless session[:flash].empty?
            status 403
            redirect to '/'
        end

        @user_info = @user.attributes.except('id', 'username', 'password_hash', 'image')

        erb :'users/edit'
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

    get '/users/:username/books' do 
        @user = User.find_by(username: params[:username])
        unless @user 
            Helpers.set_flash(session, User.error_list[:no_user], true)
            redirect to '/'
        end
        books = @user.books
        @book_info = []

        books.each_with_index do |book, i|
            @book_info << Book.attributes_to_display(book)

            @book_info[i]["google_id"] = book.google_id if book.google_id # If the book was received for the api
            @book_info[i]["id"] = book.id
            @book_info[i]["title"] = book.title
        end

        erb :'users/books'
    end
private 

    def give_token
        session[:user_id] = @user.id
    end

    def remove_token
        session.delete(:user_id)
    end

end