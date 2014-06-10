require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/flash'
require 'omniauth-github'

require_relative 'config/application'

Dir['app/**/*.rb'].each { |file| require_relative file }

helpers do
  def current_user
    user_id = session[:user_id]
    @current_user ||= User.find(user_id) if user_id.present?
  end

  def signed_in?
    current_user.present?
  end
end

def set_current_user(user)
  session[:user_id] = user.id
end

def authenticate!
  unless signed_in?
    flash[:notice] = 'You need to sign in if you want to do that!'
    redirect '/'
  end
end

get '/meetups/:id' do
  @selecting_meetup = Meetup.where(id: "#{params[:id]}").take
  erb :show
end

get '/' do
  @title = Meetup.all
  erb :index
end

get '/new_meetup' do

  erb :create_meetup
end

post '/create_meetup' do
Meetup.create(name: params['name'], location: params['location'], description: params['description'], start_time: params['start'], end_time: params['end'])
new_meet = Meetup.where(name: params['name']).first
Attendance.create(user_id: session[:user_id], meetup_id: new_meet.id, member_type: 'Admin')
end
#make sure this is best practice

get '/auth/github/callback' do
  auth = env['omniauth.auth']

  user = User.find_or_create_from_omniauth(auth)
  set_current_user(user)
  flash[:notice] = "You're now signed in as #{user.username}!"

  redirect '/'
end



get '/sign_out' do
  session[:user_id] = nil
  flash[:notice] = "You have been signed out."

  redirect '/'
end

get '/example_protected_page' do
  authenticate!
end
