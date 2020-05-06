class LiveChatController < ApplicationController

# require 'rubygems'
 require 'base64'
 require 'cgi'
 require 'openssl'
 require "json"

 def index
# raise request.remote_ip
  redirect_to :action => 'login' unless session[:user_id]
 end

 def logout
  session.delete(:user_id)
  redirect_to :action => 'login'
 end

 def login
  if (request.post? && params[:username] && ! params[:username].empty?)
   if (temp = Author.where(["username = ?", params[:username]]).first)
    session[:user_id] =	temp.id
   else
    user = Author.new(:username => params[:username])
    user.save!
    session[:user_id] = user.id
   end
   redirect_to :action => 'index'
  end
 end

 def comet
  Author.find(session[:user_id]).touch
  last_check = session[:last_live_chat_check]
  last_message = Message.select("created_at").last.created_at
  if (last_check.nil? || (last_message > last_check) || (params[:force_refresh] == "true"))
   @entries = Message.order("created_at desc").limit(50).reverse
   render :layout => false
  else
   render :plain => "f"
  end
  session[:last_live_chat_check] = Time.now
 end

 def user_list
#raise "bam"
  @authors = Author.where(["updated_at > ?", Time.now - 30]).order('username')
  render :layout => false
 end

 def new_message
  Message.new(:author_id => session[:user_id], :message => params[:message]).save!
  render :plain => "t"
 end

end
