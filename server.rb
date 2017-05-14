require "sinatra"
require "pg"
require "pry"
require "sinatra/flash"
require_relative "./app/models/article"

set :bind, '0.0.0.0'  # bind to all interfaces
set :views, File.join(File.dirname(__FILE__), "app", "views")

configure :development do
  set :db_config, { dbname: "news_aggregator_development" }
end

configure :test do
  set :db_config, { dbname: "news_aggregator_test" }
end

def db_connection
  begin
    connection = PG.connect(Sinatra::Application.db_config)
    yield(connection)
  ensure
    connection.close
  end
end

def all_forms_filled?
   @title != "" && @url != "" && @description != ""
end
def valid_title?
  @tile  
end


# Put your News Aggregator server.rb route code here
get '/' do
  redirect '/articles'
end

get '/articles' do
  @articles = db_connection do |conn|
    conn.exec("SELECT * FROM articles")
  end
  erb :index
end

get '/articles/new' do
  erb :new
end

post '/articles' do
  @title = params['title']
  @url = params['url']
  @description = params['description']
  db_connection do |conn|
    if all_forms_filled?
      conn.exec_params("INSERT INTO articles (title,url,description) VALUES ($1,$2,$3)", [@title,@url,@description])
    else
      flash[:error] = "Please completely fill out form"
      redirect "/articles"
    end
  end
  redirect "/articles"
end
