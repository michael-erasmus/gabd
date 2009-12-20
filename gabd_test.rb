require 'gabd'
require 'rubygems'
require 'test/unit'
require 'rack/test'
require 'models'
require 'hpricot'

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
  def assert_with_hpricot(assert_method)
    assert assert_method.call(last_doc)
  end
  
  def last_doc
    Hpricot.parse(last_response.body)  
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
class NewDillemaTest < SinatraTest
  
  def test_new_dilemma
    get "/new"    
    assert_equal "http://example.org/new", last_request.url    
    form = last_doc.at("form")
    assert !form.nil?
    assert_equal "post",  form.attributes["method"] 
    assert_equal "/", form.attributes["action"]
    
    assert_equal 2, (last_doc/".input").length      
  end
  
  def test_create_dilemma
    post "/",
      :text => "My dillema text" , :by => "Michael"    
    d = Dilemma.first(:text => "My dillema text", :by => "Michael")
    assert !(d.nil?)  
    follow_redirect!
    
    assert_equal "http://example.org/#{d.id}", last_request.url
  end  
  
  def test_create_dilemma_fails
    post "/", :text => "", :by => ""
      
    follow_redirect!
    assert_equal "http://example.org/new", last_request.url  
  end  
end

class LatestDillemaTest < SinatraTest
  def test_get_latest    

    Dilemma.new(:text => "text", :by => "by", :date_created => DateTime.now-1).save
    Dilemma.new(:text => "text1", :by => "by", :date_created => DateTime.now-2).save
    Dilemma.new(:text => "text3", :by => "by", :date_created => DateTime.now-3).save
    
    get "/latest"
   
    dilemmas_on_page = last_doc/".dilemma" 
    
    assert_equal Dilemma.latest.size, dilemmas_on_page.size  
  end
end

class SearchTest < SinatraTest
  def test_get_search
    get '/search'
    form = last_doc.at("form")
    assert_equal "/search", form.attributes["action"]
    assert_equal "post", form.attributes["method"]
    
    assert !last_doc.at(".input").nil?
    assert_equal "search_string", last_doc.at(".input").attributes["name"]    
  end  
  
  def test_empty_search_term
    post '/search' , :search_string => ""
    follow_redirect!
    assert_equal 'http://example.org/search', last_request.url

    assert !(last_doc.at("form").nil?)
  end  
  
  def test_post_search_not_found
    post '/search', :search_string => "will not be found"    
    assert_contains "<strong>will not be found</strong> was not found!"
  end  
  
  def test_search
     Dilemma.new(:text => "el packa", :by => "Michael", :date_created => DateTime.now-1).save
     
     post'/search', :search_string => "el packa"    
     
     #resul
  end 
end  
  
