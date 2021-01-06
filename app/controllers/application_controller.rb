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

                           

  get "/" do
    # Do a featured book when user arrives
    erb :welcome
  end

  get '/test' do 
    # look though database for matches
    book_list = Api::Googlebooks.get_books(params[:name])
    # populate database if not there
    info_to_display = Array.new
    book_list.each_with_index do |book, i|
      info_to_display << {
        title: book.title,
        image: book.image_link(:zoom => 5),
        isbn: book.isbn
      }
    end

    JSON.generate(info_to_display)
  end

end
