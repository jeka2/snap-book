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

    get '/books/search_results' do 
        title = params[:books]
        if title && title.strip != ""
            books = Book.get_book_sample(size: 20, title: title, full_info: true)
        else
            books = []
        end
        @user = User.find_by(id: Helpers.current_user(session)) if Helpers.current_user(session)

        @book_info = []
        
        books.each_with_index do |book, i|
            @book_info << Book.attributes_to_display(book)

            @book_info[i]["google_id"] = book.google_id if book.google_id # If the book was received for the api
            @book_info[i]["id"] = book.id
            @book_info[i]["title"] = book.title
        end

        erb :'books/search_results'
    end

    get '/books/:google_id' do 
        @user = User.find(Helpers.current_user(session)) if Helpers.is_logged_in?(session)
        @book = Book.find_by(google_id: params[:google_id])
        @display_info = Book.attributes_to_display(@book)

        erb :'books/book_info'
    end

    get "/user/:username/my_book/create" do
        @user = User.find_by(username: params[:username])
        if !@user || (@user.id != Helpers.current_user(session))
            status 403
            Helpers.set_flash(session, Book.error_list[:unauthorized], true)
            redirect to '/'
        end
        @create_columns = Book.columns_for_creating
        @username = params[:username]

        erb :'books/create'
    end
    
    post "/user/:username/my_book/create" do
        if User.find_by(username: params[:username]).id != Helpers.current_user(session)
            status 403
            Helpers.set_flash(session, Book.error_list[:unauthorized])
            redirect to '/'
        end

        if Book.find_by(title: params[:title])
            Helpers.set_flash(session, Book.error_list[:already_exists])
            redirect to "/user/#{params[:username]}/my_book/create"
        end
        user = User.find_by(username: params[:username])
        book = Book.new(
            params.except("username")
        )
        book.user_id = user.id
        book.save!

        user.books << book

        Helpers.set_flash(session, "Book successfully created!")
        redirect to '/'
    end

    get '/user/:username/books/:book_id/edit' do
        @user = User.find(Helpers.current_user(session)) if Helpers.current_user(session)
        book_owner = User.find_by(username: params[:username])
        @book = Book.find_by(id: params[:book_id].to_i)
        @edit_columns = Book.columns_for_creating

        Helpers.set_flash(session, User.error_list[:no_user], true) unless book_owner
        Helpers.set_flash(session, User.error_list[:not_logged_in], true) unless @user
        Helpers.set_flash(session, Book.error_list[:unauthorized], true) if (@user && (@user.id != book_owner.id)) || (@user && !@user.books.include?(@book))

        unless session[:flash].empty? 
            status 403
            redirect to '/'
        end
        
        erb :'books/edit'
    end

    get '/books/created/:id' do 
        @user = User.find(Helpers.current_user(session)) if Helpers.is_logged_in?(session)
        @book = Book.find_by(id: params[:id])
        @display_info = Book.attributes_to_display(@book)

        erb :'books/book_info'
    end

    patch '/user/:username/books/:book_id/edit' do
        resource_owner = User.find_by(username: params[:username])
        current_user = User.find_by(id: Helpers.current_user(session))
        book = Book.find_by(id: params[:book_id].to_i)

        proper_user = current_user && resource_owner && (current_user.id == resource_owner.id) ? true : false 
        Helpers.set_flash(session, Book.error_list[:unauthorized]) if !proper_user
        if book && proper_user
            Helpers.set_flash(session, Book.error_list[:unauthorized]) if book.user_id != current_user.id
        elsif !book
            Helpers.set_flash(session, Book.error_list[:no_book])
        end

        unless session[:flash].empty? 
            status 403
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

    delete '/user/:username/books/:book_id/delete' do 
        current_user = User.find_by(id: Helpers.current_user(session))
        resource_owner = User.find_by(username: params[:username])
        book = Book.find_by(id: params[:book_id].to_i)

        proper_user = current_user && resource_owner && (current_user.id == resource_owner.id) ? true : false 
        Helpers.set_flash(session, Book.error_list[:unauthorized]) if !proper_user
        if book && proper_user
            Helpers.set_flash(session, Book.error_list[:unauthorized]) if book.user_id != current_user.id
        elsif !book
            Helpers.set_flash(session, Book.error_list[:no_book])
        end

        unless session[:flash].empty? 
            status 403
            redirect to '/'
        end

        relation = UserBook.where("user_id = ? AND book_id = ?", resource_owner.id, book.id).first
        UserBook.destroy(relation.id)
        Book.find(book.id).destroy

        Helpers.set_flash(session, "The book was deleted successfully")

        redirect to '/'
    end


end