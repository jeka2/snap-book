class Book < ActiveRecord::Base
    belongs_to :author 
    belongs_to :user

    def populate_info(info)
        info_to_store = Book.column_names.reject { |col| col == "user_id" || col == "author_id" || col == "id" }
        info_to_store.each do |col|
            if col == "image"
                self.image = info.image_link(:zoom => 5)
            elsif col == "google_id"
                self.google_id = info.id
            else
                self.send("#{col}=", info.send("#{col}"))
            end
        end
    end

    def self.get_book_sample(size:,title:)
        books_in_database = Book.where("title LIKE ?", "%#{title}%").limit(size)
        info_to_send = Array.new
        books_to_display = size
        additional_books_to_display = books_to_display - books_in_database.size

        if books_in_database
            books_in_database.each do |book| 
                info_to_send << {
                    title: book.title,
                    image: book.image,
                    id: book.google_id
                }
            end
        end
        # There will be 5 books displayed in the search bar
        # If those aren't in the database yet, the api call
        # Will be made for the remainder
        if additional_books_to_display > 0
            book_list = Api::Googlebooks.get_books(title, {:count => 10})
            book_list.each do |book|
                duplicate = false
                # The database info may already contain a book in the list
                info_to_send.each { |b| duplicate = true if b[:id] == book.id }
                
                unless duplicate
                    new_book = Book.new
                    new_book.populate_info(book)
                    new_book.save!

                    info_to_send << {
                        title: book.title,
                        image: book.image_link(:zoom => 5),
                        id: book.id
                    }
                end
                break if info_to_send.size == size
            end
        end
        JSON.generate(info_to_send)
    end
end 