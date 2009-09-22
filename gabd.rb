require 'rubygems'
require 'sinatra'
require 'models'

get '/:id' do
  @dilemma = Dilemma.get!(params['id'])
  haml :view
end






