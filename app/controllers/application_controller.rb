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

end
