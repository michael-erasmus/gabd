require 'test/unit'
require 'models'


class ModelsTest < Test::Unit::TestCase
  def test_sluggify
    assert_equal "should-this-string-be-sluggified", "should this string be sluggified?".sluggify
  end
  
  def test_dilemma_text_has_correct_slug
    d = Dilemma.new(:text => "Should I make good suggestions or evil ones?")    
    assert_equal d.text.sluggify, d.id
  end  
  
  def test_has_text_and_by_check
    d = Dilemma.new 

    assert !d.save    
    assert_equal "You didn't write anything!", d.errors[:text][0]
    assert_equal "Please enter your name", d.errors[:by][0]
  end
  
  def test_suggestions
    d = Dilemma.new(:text => "Should I make good suggestions or evil ones?", :by => "Michael")    
    evil_s  = d.add_evil_suggestion("Devil advice is more fun!", "John")
    good_s = d.add_good_suggestion("Good suggestions!, it's uplifiting!", "Peter")    
    d.save 
    
    assert_equal 1, d.evil_suggestions.size
    assert_equal 1, d.good_suggestions.size
  end  
  
  def teardown
      Dilemma.all.destroy!
      Suggestion.all.destroy!
  end
    
  def test_latest_dillemas
    Dilemma.new(:text => "text", :by => "by", :date_created => DateTime.now-1).save
    Dilemma.new(:text => "text1", :by => "by", :date_created => DateTime.now-2).save
    Dilemma.new(:text => "text3", :by => "by", :date_created => DateTime.now-3).save
    
    assert_equal Dilemma.all(:date_created => ((DateTime.now - 2)..DateTime.now)), Dilemma.latest
  end 
end
