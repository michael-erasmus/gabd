require 'gabd'
require 'rubygems'
require 'test/unit'
require 'rack/test'

set :environment, :test

class ViewDillemaTest < Test::Unit::TestCase
    include Rack::Test::Methods
    def setup
      #Add a test Dilemma record     
      @dilemma = Dilemma.new(:text =>"Should I give good suggestions or evil ones?", :by => "Michael") 
      assert @dilemma.save  
      @dilemma.add_evil_suggestion("Evil ones!", "Peterdevil")
      @dilemma.add_good_suggestion("Good ones!", "angelPeter")      
      assert @dilemma.save      
      
      get "/#{@dilemma.id}" 
    end
    
    def teardown
      @dilemma.destroy()
    end
    
    def app
      Sinatra::Application
    end
    
    def test_show_dilemma
      assert last_response.body.include?(@dilemma.text), "Does not contain the Dilemma text"
      assert last_response.body.include?("<h3>asks <strong>#{@dilemma.by}</strong></h3>"), 
        "Does not contain person whom has the dilemma"
    end  
    
    def test_has_evil_suggestions      
      assert last_response.body.include?("Peterdevil") ,  "Does not contain the evil person"
      assert last_response.body.include?("Evil ones!"), "Does not contain the evil text"
    end
    
    def test_has_good_suggestions
      assert last_response.body.include?("angelPeter") ,  "Does not contain the good person"
      assert last_response.body.include?("Good ones!"), "Does not contain the good text"
    end
end