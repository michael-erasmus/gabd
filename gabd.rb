require 'rubygems'
require 'sinatra'
require 'models'

get '/:dillema_slug' do
  @dillema = Dillema.first(:slug => params[':dillema_slug'])
  haml :view
end




class String
  def sluggify
    slug = self.downcase.gsub(/[^0-9a-z_ -]/i, '')
    slug = slug.gsub(/\s+/, '-')
    slug
  end
end

class NilClass
  def sluggify
    ''
  end
end

