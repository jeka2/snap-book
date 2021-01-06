class BooksController < ApplicationController
    get '/books/search_bar' do 
        return JSON.generate([]) if params[:title].strip == ""

        books_in_database = Book.where("title LIKE ?", "%#{params[:title]}%").limit(5)
        info_to_display = Array.new
        books_to_display = 5
        additional_books_to_display = books_to_display - books_in_database.size

        if books_in_database
            books_in_database.each do |book| 
                info_to_display << {
                    title: book.title,
                    image: book.image,
                    id: book.google_id
                }
            end
        end
        # There will be 5 books displayed in the search bar
        # If those aren't in the database yet, the api call
        # Will be made for the remainder
        if additional_books_to_display
            book_list = Api::Googlebooks.get_books(params[:title], {:count => additional_books_to_display})
            book_list.each do |book|
                Book.create(title: book.title, isbn: book.isbn, image: book.image_link, description: book.description, google_id: book.id)
                info_to_display << {
                    title: book.title,
                    image: book.image_link(:zoom => 5),
                    id: book.id
                }
            end
        end
        JSON.generate(info_to_display)
  end

  get '/books/:google_id' do 
    book = Book.find_by(google_id: params[:google_id])
  end
end