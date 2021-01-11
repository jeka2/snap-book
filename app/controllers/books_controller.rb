class BooksController < ApplicationController
    get '/books/search_bar' do 
        Book.get_book_sample(size: 5, title: params[:title])
    end

    post '/books/self_add' do 
        user = User.find(Helpers.current_user(session))
        book = Book.find(params[:book_id].to_i)

        user.books << book
    end

    delete '/books/self_remove' do 
        user = User.find(Helpers.current_user(session))
        book = Book.find(params[:book_id].to_i)

        relation = UserBook.where("user_id = ? AND book_id = ?", user.id, book.id).first
        UserBook.destroy(relation.id)
    end

    get '/books/:google_id' do 
        @user = User.find(Helpers.current_user(session)) if Helpers.is_logged_in?(session)
        @book = Book.find_by(google_id: params[:google_id])
        @display_info = Book.attributes_to_display(@book)

        erb :'books/book_info'
    end

    get "/user/:username/my_book/create" do
        if User.find_by(username: params[:username]).id != Helpers.current_user(session)
            status 403
            session[:flash] << ["You may not view this resource"]
            redirect to '/'
        end
        @create_columns = Book.columns_for_creating
        @username = params[:username]

        erb :'books/create'
    end
    
    post "/user/:username/my_book/create" do
        if User.find_by(username: params[:username]).id != Helpers.current_user(session)
            status 403
            session[:flash] << ["You may not view this resource"]
            redirect to '/'
        end

        if Book.find_by(title: params[:title])
            session[:flash] << ["Title by that name already exists"]
            redirect to "/user/#{params[:username]}/my_book/create"
        end
        user = User.find_by(username: params[:username])
        book = Book.new(
            params.except("username")
        )
        book.user_id = user.id
        book.save!

        user.books << book
        redirect to '/'
    end

    get '/user/:username/books/:book_id/edit' do
        @user = User.find(Helpers.current_user(session)) if Helpers.current_user(session)
        book_owner = User.find_by(username: params[:username])
        @book = Book.find(params[:book_id])
        @edit_columns = Book.columns_for_creating

        if !book_owner 
            status 403
            session[:flash] << ["No such user"]
            redirect to '/'
        elsif @user && (@user.id != book_owner.id)
            status 403
            session[:flash] << ["You may not edit another person's books"]
            redirect to '/'
        elsif !@user.books.include?(@book)
            status 403
            session[:flash] << ["This book does not belong to you"]
            redirect to '/'
        end
        
        erb :'books/edit'
    end

    patch '/user/:username/books/:book_id/edit' do
        resource_owner = User.find_by(username: params[:username])
        current_user = Helpers.current_user(session)
        book = Book.find(params[:book_id])

        if resource_owner.id != current_user
            status 403
            flash[:session] << ["You are not allowed to edit this"]
            redirect to '/'
        end

        params.each do |k, v|
            if book.respond_to?(k)
                if book.column_for_attribute(k).type == :integer
                    book[k] = v.to_i
                elsif book.column_for_attribute(k).type == :string
                    book[k] = v.strip
                end
            end
        end
        book.save!

        redirect to '/'
    end 

    get '/books/created/:id' do 
        @user = User.find(Helpers.current_user(session)) if Helpers.is_logged_in?(session)
        @book = Book.find(params[:id])
        @display_info = Book.attributes_to_display(@book)

        erb :'books/book_info'
    end

    delete '/user/:username/books/:book_id/delete' do 
        current_user = User.find(Helpers.current_user(session))
        resource_owner = User.find_by(username: params[:username])
        book = Book.find(params[:book_id])
        
        if !current_user || !resource_owner || !book || (current_user.id != resource_owner.id)
            session[:flash] << ["You are not allowed to edit this resource"]
            redirect to '/'
        end

        relation = UserBook.where("user_id = ? AND book_id = ?", resource_owner.id, book.id).first
        UserBook.destroy(relation.id)

        redirect to '/'
    end


end