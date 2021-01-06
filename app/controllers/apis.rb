module Api
    class Goodreads
        def self.books_by_author(author_name)
            client.author_by_name(author_name)
        end

        def self.author_info(author_id)
            client.author(author_id)
        end

        def self.books_by_title(title)
            client.book_by_title(title)
        end

        def self.client
            key = ENV["GOODREADS_API_KEY"]
            secret = ENV["GOODREADS_API_SECRET"]
            Goodreads.new(api_key: key)
        end
    end

    class Googlebooks
        def self.get_books(key_word, param)
            GoogleBooks.search(key_word, param)
        end
    end
end