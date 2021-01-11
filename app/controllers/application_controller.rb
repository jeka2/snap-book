require './config/environment'
require 'json'

class ApplicationController < Sinatra::Base

  configure do
    set :public_folder, 'public'
    set :views, 'app/views'
  end

  use Rack::Session::Cookie, :key => 'rack.session',
                           :path => '/',
                           :secret => 'your_secret'


  after do 
    if request.request_method == "GET"
        session[:flash] = []
    end
  end

  not_found do 
    status 404
    erb :'404'
  end

  get "/" do
    # Do a featured book when user arrives
    if Book.count > 0 # If any books in the database
      found = false
      while !found
        begin
          random_index = rand(1..Book.last.id)
          @book = Book.find(random_index)
        rescue ActiveRecord::RecordNotFound

        else
          found = true
        end
      end
    else
      choices = ["nouns", "adjs"]
      found = false
      while !found
        random_word = RandomWord.send(choices.sample, not_longer_than: 20).next
        @book = Book.random_one_from_api
        found = true if @book
      end
    end

    @book = Book.random_book
  
    @user = User.find(Helpers.current_user(session)) if Helpers.current_user(session)
    @display_info = Book.attributes_to_display(@book)

    erb :'books/book_info'
  end

end
