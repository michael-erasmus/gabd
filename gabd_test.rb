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
	def assert_contains(text)
 		assert last_response.body.include?(text), "Does not contain #{text}"
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
      assert_contains @dilemma.text
      assert_contains "h3>asks <strong>#{@dilemma.by}</strong></h3>"
    end  
    
    def test_has_evil_suggestions            
      assert_contains "Peterdevil"
      assert_contains "Evil ones!"
    end
    
    def test_has_good_suggestions
      assert_contains "angelPeter"
      assert_contains "Good ones!"
    end
end

class BrowseDillemasTest < SinatraTest
	def setup
		@dilemma_good_or_evil = Dilemma.new(:text =>"Should I give good suggestions or evil ones?", :by => "John")
		@dilemma_should_i_lie = Dilemma.new(:text =>"Should I lie to make myself look good?", :by => "Paul")
		@dilemma_good_or_evil.save
		@dilemma_should_i_lie.save
	end		

	def teardown
    Dilemma.all.destroy!
  end

	def test_browse
		get "/"
		
		assert_contains @dilemma_good_or_evil.by
		assert_contains @dilemma_good_or_evil.text
		assert_contains @dilemma_should_i_lie.by
		assert_contains @dilemma_should_i_lie.text		
		assert_contains "<a href='/#{@dilemma_good_or_evil.id}'>"
	end					
end	

class EditSuggestionTest < SinatraTest

  def setup
    @dilemma = Dilemma.new(:text =>"Should I give good suggestions or evil ones?", :by => "Michael") 
    assert @dilemma.save  
  end

  def teardown
    Dilemma.all.destroy!
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
    assert_contains "Peter"
    assert_contains "Pure evil!"
  end

  def test_add_good_suggestion
    post "/#{@dilemma.id}/good_suggestions",
      :text => "Pure good!", :by => "Michael" 
    follow_redirect!
    
    assert_equal "http://example.org/should-i-give-good-suggestions-or-evil-ones", last_request.url
    
    d = Dilemma.get!(@dilemma.id)
    assert_equal 1, d.good_suggestions.size
    assert_equal "Pure good!", d.good_suggestions.first.text
    assert_equal "Michael", d.good_suggestions.first.by
    assert_contains "Michael"
    assert_contains "Pure good!"
  end
end
