require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/flash'
require 'omniauth-github'
require 'pry'

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

def check_attendance(user, meetup)
  form = nil
  check = Attendance.where(user_id: user, meetup_id: meetup).first
  if check == nil
    form = 'Join'
  else
    form = 'Leave'
  end
  form
end

################# User Oriented ###################

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

############## None User Oriented ##############

get '/' do
  @title = Meetup.all.order(:name)
  erb :index
end

get '/meetups/:id' do
  @selecting_meetup = Meetup.where(id: "#{params[:id]}").first
  @users = @selecting_meetup.users
  @button = check_attendance(session[:user_id], params[:id])
  erb :show
end

get '/new_meetup' do

  erb :create_meetup
end

################## Posts #########################

post '/create_meetup' do
  authenticate!
  @meetup = Meetup.create(name: params['name'], location: params['location'], description: params['description'], start_time: params['start'], end_time: params['end'])
  Attendance.create(user_id: session[:user_id], meetup_id: @meetup.id, member_type: 'Admin')
  flash[:notice] = "You created a new meetup called #{@meetup.name}!"
  redirect "/meetups/#{@meetup.id}"
end

post '/join_meetup/:id' do
  authenticate!
  if params.has_key?('Join')
    new_attendance = Attendance.create(user_id: session[:user_id], meetup_id: params['Join'], member_type: 'Guest')
    flash[:notice] = "You joined this group!"
    redirect "/meetups/#{new_attendance.meetup_id}"
  else
    Attendance.destroy_all("user_id = #{session[:user_id]} AND meetup_id = #{params['Leave']}")
    flash[:notice] = "You left this group!"
    redirect "/meetups/#{params[:id]}"
  end
end




