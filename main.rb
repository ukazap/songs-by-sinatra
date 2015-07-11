require 'sinatra'
require 'sinatra/reloader' if development?
require 'haml'
require 'sass'
require './song'

configure do
  enable :sessions
  set :username, 'frank'
  set :password, 'sinatra'
end

configure :development do
  DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/development.sqlite3")
end

configure :production do
  DataMapper.setup(:default, ENV['DATABASE_URL'])
end

get('/styles.css'){ scss :styles }

get '/' do
  haml :home
end

get '/about' do
  @title = "All About This Website"
  haml :about
end

get '/contact' do
  haml :contact
end

not_found do
  haml :not_found
end

get '/fake-error' do
  status 500
  'There\'s nothing wrong, really :P'
end

get '/songs' do
  @songs = Song.all
  haml :songs
end

get '/songs/new' do
  halt(401,'Not Authorized') unless session[:admin]
  @song = Song.new
  haml :new_song
end

get '/songs/:id' do
  @song = Song.get(params[:id])
  haml :show_song
end

post '/songs' do
  halt(401,'Not Authorized') unless session[:admin]
  song = Song.create(params[:song])
  redirect to("/songs/#{song.id}")
end

get '/songs/:id/edit' do
  halt(401,'Not Authorized') unless session[:admin]
  @song = Song.get(params[:id])
  haml :edit_song
end

put '/songs/:id' do
  halt(401,'Not Authorized') unless session[:admin]
  song = Song.get(params[:id])
  song.update(params[:song])
  redirect to("/songs/#{song.id}")
end

delete '/songs/:id' do
  halt(401,'Not Authorized') unless session[:admin]
  Song.get(params[:id]).destroy
  redirect to('/songs')
end

get '/login' do
  redirect to('/songs') if session[:admin]
  haml :login
end

post '/login' do
  if params[:username] == settings.username && params[:password] == settings.password
    session[:admin] = true
    redirect to('/songs')
  else
    haml :login
  end
end

get '/logout' do
  session.clear
  redirect to('/login')
end