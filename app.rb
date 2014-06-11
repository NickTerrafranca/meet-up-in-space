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


get '/sign_out' do
  session[:user_id] = nil
  flash[:notice] = "You have been signed out."

  redirect '/'
end

get '/example_protected_page' do
  authenticate!
end

get '/auth/github/callback' do
  auth = env['omniauth.auth']

  user = User.find_or_create_from_omniauth(auth)
  set_current_user(user)
  flash[:notice] = "You're now signed in as #{user.username}!"

  redirect '/'
end

#All us!************************************
# get requests ###########################

def member?(user_id, meetup_id)
  Attendance.where(user_id: user_id, meetup_id: meetup_id).empty?
end

get '/meetups/:id' do
  @selecting_meetup = Meetup.where(id: "#{params[:id]}").take
  @users = @selecting_meetup.users
  erb :show
end

get '/' do
  @title = Meetup.all.order(:name)
  erb :index
end

get '/new_meetup' do

  erb :create_meetup
end

#post requests

post '/create_meetup' do
  if signed_in?
    @meetup = Meetup.create(name: params['name'], location: params['location'], description: params['description'], start_time: params['start'], end_time: params['end'])
    Attendance.create(user_id: session[:user_id], meetup_id: @meetup.id, member_type: 'Admin')
    redirect "/meetups/#{@meetup.id}"
  else
    flash[:notice] = "You must be signed in to create a meet up."
    redirect '/'
  end
end

post '/join_meetup' do
  if signed_in?
    if member?(session[:user_id], params[:id])
      new_attendance = Attendance.create(user_id: session[:user_id], meetup_id: params[:id], member_type: "Admin")
      redirect "/meetups/#{params[:id]}"
    else
      flash[:notice] = "You are already a member!"
      redirect "/meetups/#{params[:id]}"
    end
  else
    flash[:notice] = "You must be signed in to join a meet-up."
    redirect "/meetups/#{params[:id]}"
  end

end

post '/unsubscribe' do
  if signed_in?

    if member?(session[:user_id], params[:id]) == false

      new_attendance = Attendance.delete_all(user_id: session[:user_id], meetup_id: params[:id])

      redirect "/meetups/#{params[:id]}"
    else
      flash[:notice] = "You are already a member!"
      redirect "/meetups/#{params[:id]}"
    end
  else
    flash[:notice] = "You must be signed in to unsubscribe from a meet-up."
    redirect "/meetups/#{params[:id]}"
  end
end

