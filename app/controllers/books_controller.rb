class BooksController < ApplicationController
    get '/books/search_bar' do 
        Book.get_book_sample(size: 5, title: params[:title])
    end

    post '/books/add_remove_from_me' do 
        user = User.find(Helpers.current_user(session))
        book =  Book.find(params[:book_id].to_i)

        if user.books.include?(book)
            relation = UserBook.where(user_id: user.id, book_id: book.id).first
            UserBook.destroy(relation.id)
        else
            user.books << book
        end 
    end

    get '/books/:google_id' do 
        @user = User.find(Helpers.current_user(session)) if Helpers.is_logged_in?(session)
        @book = Book.find_by(google_id: params[:google_id])
        @display_info = Book.attributes_to_display(@book)

        erb :'books/book_info'
    end
end