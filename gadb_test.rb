require 'gabd'
require 'rubygems'
require 'test/unit'
require 'rack/test'
require 'models'

set :environment, :test

class SinatraTest < Test::Unit::TestCase
 include Rack::Test::Methods
  def app
      Sinatra::Application
  end
  def test_true
    assert true
  end
end

class ViewDillemaTest < SinatraTest    
    
    def setup
      #Add a test Dilemma record     
      @dilemma = Dilemma.new(:text =>"Should I give good suggestions or evil ones?", :by => "Michael") 
      @dilemma.save
      @dilemma.add_evil_suggestion("Evil ones!", "Peterdevil")
      @dilemma.add_good_suggestion("Good ones!", "angelPeter")      
      assert @dilemma.save      
      
      get "/#{@dilemma.id}" 
    end
    
    def teardown
      Dilemma.all.destroy!
      Suggestion.all.destroy!
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

class EditSuggestionTest < SinatraTest

  def setup
    @dilemma = Dilemma.new(:text =>"Should I give good suggestions or evil ones?", :by => "Michael") 
    assert @dilemma.save  
  end
  def teardown
    @dilemma.destroy
  end
  
  def test_add_evil_suggestion
    post "/#{@dilemma.id}/evil_suggestions",
      :text => "Pure evil!", :by => "Peter" 
    follow_redirect!
    
    assert_equal "http://example.org/should-i-give-good-suggestions-or-evil-ones", last_request.url
    
    d = Dilemma.get!(@dilemma.id)
    assert_equal 1, d.evil_suggestions.size
    assert_equal "Pure evil!", d.evil_suggestions.first.text
    assert_equal "Peter", d.evil_suggestions.first.by
    puts last_response.body
    assert last_response.body.include?("Peter") , "Does not contain the evil person"
    assert last_response.body.include?("Pure evil!"), "Does not contain the evil text"          
  end
end