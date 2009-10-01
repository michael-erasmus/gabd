require 'rubygems'
require 'sinatra'
require 'models'

get '/' do
	#@dilemmas = Dilemma.all(:limit => 10, :order => [suggestions_count.desc])							
	@dilemmas = Dilemma.all()							
	haml :browse
end				

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

post '/:id/good_suggestions' do  
  @dilemma = Dilemma.get!(params['id'])  
  @dilemma.add_good_suggestion(params['text'], params['by'])
  @dilemma.save  
  redirect "/#{@dilemma.id}"
end


helpers do

  def partial(template, *args)
    options = args.last.is_a?(Hash) ? args.last : {}
    options.merge!(:layout => false)
    if collection = options.delete(:collection) then
      collection.inject([]) do |buffer, member|
        buffer << haml(template, options.merge(
                                  :layout => false, 
                                  :locals => {template.to_sym => member}
                                )
                     )
      end.join("\n")
    else
      haml(template, options)
    end
  end
end


