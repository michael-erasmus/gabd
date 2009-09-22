require 'rubygems'
require 'dm-core'
require 'dm-validations' 
require 'dm-timestamps'
require 'dm-aggregates'
require 'dm-constraints'

 
DataMapper.setup(:default, ENV['DATABASE_URL'] || 'sqlite3://db/budget.sqlite3')

class Dilemma
  include DataMapper::Resource 
  
  has n, :suggestions
  
  property :id, String, :length => 280, 
    :key => true,
    :default => Proc.new {|r, p| r.text.sluggify if r.text} 
    
  property :text, String, :length => 140, :nullable => false, :unique => true,
    :messages => { 
      :presence => "You didn't write anything!", 
      :is_unique => "Someone has posted this dilemma before!"
    }
  property :by, String , :length => 50, :nullable => false,
    :messages => { 
      :presence => "Please enter your name"
    }
    
    def add_evil_suggestion(text, by)      
      suggestions.build(:text => text, :by => by, :type => "e").save 
    end
    
    def add_good_suggestion(text, by)      
      suggestions.build(:text => text, :by => by, :type => "g").save      
    end
    def good_suggestions
      suggestions.all(:type => 'g')
    end
    def evil_suggestions
      suggestions.all(:type => 'e')
    end
end  

class Suggestion 
  include DataMapper::Resource 
  
  belongs_to :dilemma
  
  property :id , Serial
  
  property :text, String, :length => 140, :nullable => false,  
    :messages => { :presence => "You didn't write anything!" }
    
  property :dilemma_id, String, :length => 280  
  property :by, String , :length => 50, :nullable => false,
    :messages => { :presence => "Please enter your name"}  
    
  property :type, String,  :length => 1 ,   :format => lambda {|s| s == "g" or s == "e" }
  property :date_created, DateTime, :default => Time.now 
  validates_is_unique :text, :scope => :dilemma_id,    
    :message => "Someone already said that!"
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

DataMapper.auto_migrate!