#!/usr/bin/ruby

require 'rubygems'
require 'sinatra'
require 'erb'
require 'redcloth'
require 'mongomapper'
require 'models/storybit'

# Basic Sinatra setings
set :views, File.dirname(__FILE__) + '/views'
set :port, 12345
enable :sessions # For flash messages

# Choose our MongoDB database
MongoMapper.database = 'story'

###########################################################
###########################################################


# The index page with the submissions and form
get "/" do
  @storybits = Storybit.all(:order => '_id')
  custom_render_erb :index
end

# Saving a submission
post "/" do
  storybit = Storybit.create({
      :name => params[:name],
      :body => params[:body],
      :tags => params[:tags].split
    })
  if !storybit.save
    flash[:error] = storybit.errors.full_messages
  end
  redirect "/"
end

# Viewing comments
get "/comments/:id" do
  @storybit = Storybit.find(params[:id])
  custom_render_erb :comments
end

# Adding comments
post "/comments" do
  @storybit = Storybit.find(params[:id])
  comment = Comment.new(:name => params[:name], :body => params[:body])
  if comment.valid?
    @storybit.comments << comment
    @storybit.save
  else
    flash[:error] = comment.errors.full_messages
  end
  redirect "/comments/#{params[:id]}"
end

# Searching on tags
get "/tags/:tag" do
  @tag = params[:tag]
  @storybits = Storybit.all(:conditions => { :tags => @tag }, :order => '_id')
  custom_render_erb :tags
end

###########################################################
###########################################################


# Enable support for saving flash messages
# to our session object, similar to how Rails does it
def flash
  session[:flash] = {} if session[:flash] && session[:flash].class != Hash
  session[:flash] ||= {}
end

# Needed to clear the flash after it is displayed
def custom_render_erb(*args)
  myerb = erb(*args)
  flash.clear
  myerb
end


helpers do
  include Rack::Utils
  alias_method :h, :escape_html
  
  # Filter text using Textile
  def redcloth(str)
    RedCloth.new(str, [ :sanitize_html ]).to_html
  end
end