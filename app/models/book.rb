class Book < ActiveRecord::Base
    belongs_to :author 
    has_many :user_books
    has_many :users, through: :user_books

    def populate_info(info)
        info_to_store = self.class.column_names.reject { |col| col == "user_id" || col == "author_id" || col == "id" }
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

    def self.get_book_sample(size:,title:,full_info:false)
        # Books in the database will be prioritized for efficiency
        books_from_database = self.many_from_database(size, title, full_info)
        additional_amount = size - books_from_database.size
        books_from_api = self.many_from_api(additional_amount, title, full_info, books_from_database) if additional_amount > 0

        info_to_send = books_from_api ? books_from_database + books_from_api : books_from_database

        unless full_info # If not full info, the results are for the search bar
            JSON.generate(info_to_send)
        else
            info_to_send
        end
    end

    def self.random_book
        sources = ["database", "api"]
        if sources.sample == "database"
            book = random_one_from_database
            book = random_one_from_api unless book # Only if no books yet
            book
        else
            random_one_from_api
        end
    end

    def self.attributes_to_display(book)
        all_info = book.attributes.except('id', 'title', 'image', 'author_id', 'user_id', 'google_id')
        display_info = Hash.new

        all_info.each do |k,v|
            next unless v && v != ""
            display_info[k] = v
        end
        display_info
    end

    def self.random_one_from_database
        if self.count > 0 # If any books in the database
            found = false
            while !found
                begin
                    random_index = rand(1..Book.last.id)
                    book = self.find(random_index)
                rescue ActiveRecord::RecordNotFound

                else
                    found = true
                end
            end
            book
        else
            nil
        end
    end

    def self.random_one_from_api
        choices = ["nouns", "adjs"]
        found = false
        while !found
            random_word = RandomWord.send(choices.sample, not_longer_than: 20).next
            book = self.many_from_api(1, Helpers.displayable_version(random_word), true)
            found = true if book
        end
        book[0]
    end

    def self.many_from_database(amount, title, full_info = false)
        info_to_send = Array.new
        books_in_database = self.where("title LIKE ?", "%#{title}%").limit(amount)

        if books_in_database
            books_in_database.each do |book| 
                if full_info
                    info_to_send << book
                else
                    info_to_send << {
                        title: book.title,
                        image: book.image,
                        id: book.google_id
                    }
                end
            end
        end
        info_to_send
    end

    def self.many_from_api(amount, title, full_info=false, potential_duplicates = [])
        info_to_send = Array.new
        book_list = Api::Googlebooks.get_books(title, {:count => 10})
        book_list.each do |book|
            duplicate = false
            # The database info may already contain a book in the list
            potential_duplicates.each { |b| duplicate = true if b[:id] == book.id }
                
            unless duplicate
                new_book = self.new
                new_book.populate_info(book)
                new_book.save!

                if full_info 
                    info_to_send << new_book
                else
                    info_to_send << {
                    title: book.title,
                    image: book.image_link(:zoom => 5),
                    id: book.id
                }
                end
            end
            break if info_to_send.size == amount
        end
        info_to_send
    end

    ####

    def self.columns_for_creating
        self.column_names.reject do |col|
            col == 'id' || col == 'isbn' || col == 'image' || col == 'author_id' || col == 'user_id' || col == 'google_id' || col == 'publisher' || col =='info_link'
        end
    end

    def self.error_list
        {
            unauthorized: "You are not authorized to view this resource",
            already_exists: "Title by that name already exists",
        }
    end

end 