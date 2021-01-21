module Api
    class Googlebooks
        def self.get_books(key_word, param)
            GoogleBooks.search(key_word, param)
        end
    end
end