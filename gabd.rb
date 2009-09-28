require 'rubygems'
require 'sinatra'
require 'models'

get '/:id' do
  @dilemma = Dilemma.get!(params['id'])
  haml :view
end

post '/:id/evil_suggestions' do  
  @dilemma = Dilemma.get!(params['id'])  
  @dilemma.add_evil_suggestion(params['text'], params['by'])
  @dilemma.save  
  redirect "/#{@dilemma.id}"
end






