class BooksController < ApplicationController
    get '/books/search_bar' do 
        Book.get_book_sample(size: 5, title: params[:title])
    end

    post '/books/add_to_me' do 
        user = User.find(Helpers.current_user(session))
        book =  book.find(params[:book_id].to_i)
        if !user.books.includes?(book)
           user.books << book 
        end 

    end

    get '/books/:google_id' do 
        @book = Book.find_by(google_id: params[:google_id])

        erb :'books/book_info'
    end
end