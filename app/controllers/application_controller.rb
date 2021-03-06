require "./config/environment"
require "./app/models/user"
require "pry"
class ApplicationController < Sinatra::Base

  configure do
    set :views, "app/views"
    enable :sessions
    set :session_secret, "password_security"
  end

  get "/" do
    erb :index
  end

  get "/signup" do
    erb :signup
  end

  post "/signup" do
    if params.all? {|key, value| value != ""}
      user = User.new(username: params[:username], password: params[:password])
      user.save
      redirect '/login'
    else
      redirect '/failure'
    end
  end

  get '/account' do
    @user = User.find(session[:user_id])
    erb :account
  end

  post '/account/deposit' do
    @user = User.find(session[:user_id])
    new_balance = @user.balance.to_f + params[:deposit].to_f
    @user.update(balance: new_balance)
    redirect '/account'
  end

  post '/account/withdrawal' do
    @user = User.find(session[:user_id])
    if @user.balance.to_f >= params[:withdrawal].to_f
      new_balance = @user.balance.to_f - params[:withdrawal].to_f
      @user.update(balance: new_balance)
      redirect '/account'
    else
      erb :withdrawal_failure
    end
  end


  get "/login" do
    erb :login
  end

  post "/login" do
    @user = User.find_by(username: params[:username])

    if @user && @user.authenticate(params[:password])
      session[:user_id] = @user.id
      redirect '/account'
    else
      redirect '/failure'
    end
  end

  get "/success" do
    if logged_in?
      erb :success
    else
      redirect "/login"
    end
  end

  get "/failure" do
    erb :failure
  end

  get "/logout" do
    session.clear
    redirect "/"
  end

  helpers do
    def logged_in?
      !!session[:user_id]
    end

    def current_user
      User.find(session[:user_id])
    end
  end


end
