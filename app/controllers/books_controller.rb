class BooksController < ApplicationController

    get '/books/search_bar' do 
        Book.get_book_sample(size: 5, title: params[:title])
    end

    post '/books/self_add' do 
        user = User.find_by_id(Helpers.current_user(session))
        book = Book.find_by_id(params[:book_id])

        user.books << book unless user.books.exists?(book)
    end

    delete '/books/self_remove' do 
        user = User.find_by_id(Helpers.current_user(session))
        book = Book.find_by_id(params[:book_id])

        relation = UserBook.where("user_id = ? AND book_id = ?", user.id, book.id).first
        UserBook.destroy(relation.id) if relation
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

        unless authenticated?(user: @user)
            session[:from_get] = true
            status 404
            redirect to '/' 
        end

        @create_columns = Book.columns_for_creating
        @username = params[:username]

        erb :'books/create'
    end
    
    post "/user/:username/my_book/create" do
        user = User.find_by(username: params[:username])

        unless authenticated?(user: user)
            status 403
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
        @user = User.find_by(username: params[:username])
        @book = Book.find_by_id(params[:book_id])

        unless authenticated?(user: @user, book: @book)
            session[:from_get] = true
            status 403
            redirect to '/' 
        end

        @edit_columns = Book.columns_for_creating
        
        erb :'books/edit'
    end

    get '/books/created/:id' do 
        @user = User.find(Helpers.current_user(session)) if Helpers.is_logged_in?(session)
        @book = Book.find_by_id(params[:id])
        @display_info = Book.attributes_to_display(@book)

        erb :'books/book_info'
    end

    patch '/user/:username/books/:book_id/edit' do
        user = User.find_by(username: params[:username])
        book = Book.find_by_id(params[:book_id])

        redirect to '/' unless authenticated?(user: user, book: book)

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

        Helpers.set_flash(session, "The book was updated successfully")

        redirect to '/'
    end 

    delete '/user/:username/books/:book_id/delete' do 
        user = User.find_by(username: params[:username])
        book = Book.find_by_id(params[:book_id])

        redirect to '/' unless authenticated?(user: user, book: book)

        unless session[:flash].empty? 
            status 403
            redirect to '/'
        end

        relation = UserBook.where("user_id = ? AND book_id = ?", user.id, book.id).first
        UserBook.destroy(relation.id)
        Book.find(book.id).destroy

        Helpers.set_flash(session, "The book was deleted successfully")

        redirect to '/'
    end

private

    def authenticated?(user:nil, book:'Not provided')
        if user && user.id == Helpers.current_user(session)
            if book && book != 'Not provided'
                if user.books.exists?(book)
                    return true
                else
                    Helpers.set_flash(session, Book.error_list[:unauthorized])
                    return false
                end
            elsif book && book == "Not provided"   
                return true
            elsif book.nil?
                Helpers.set_flash(session, Book.error_list[:no_book])
                return false
            end
        else
            Helpers.set_flash(session, Book.error_list[:unauthorized])
            return false
        end
    end
end