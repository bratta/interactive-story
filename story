#!/usr/bin/ruby

require 'rubygems'
require 'sinatra'
require 'erb'
require 'rack-flash'
require 'redcloth'
require 'mongomapper'
require 'models/storybit'

# Basic Sinatra setings
use Rack::Flash
enable :sessions # For flash messages
set :views, File.dirname(__FILE__) + '/views'
set :port, 12345

# Choose our MongoDB database
MongoMapper.database = 'story'

###########################################################
###########################################################


# The index page with the submissions and form
get "/" do
  @storybits = Storybit.all(:order => '_id')
  erb :index
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
  erb :comments
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


helpers do
  include Rack::Utils
  alias_method :h, :escape_html
  
  # Filter text using Textile
  def redcloth(str)
    RedCloth.new(str, [ :sanitize_html ]).to_html
  end
end