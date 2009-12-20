require 'rubygems'
require 'sinatra'
require 'models'
require 'haml'

get '/' do
	#@dilemmas = Dilemma.all(:limit => 10, :order => [suggestions_count.desc])							
	@dilemmas = Dilemma.all()							
	haml :browse
end				

get '/latest' do
  @dilemmas = Dilemma.latest							
  haml :browse
end

get '/search' do
    haml :search
end  

get '/new' do 
  @dilemma = Dilemma.new
  haml :new
end  

get '/:id' do
  @dilemma = Dilemma.get!(params['id'])
  haml :view
end

post '/search' do
  @search_string = params['search_string'] 
  redirect '/search' if @search_string == ""
  haml :results
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

post '/' do
    @dilemma = Dilemma.new(:text => params['text'], :by => params['by'])
    if @dilemma.save
      redirect "/#{@dilemma.id}"
    else
      redirect "/new"  
    end  
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


