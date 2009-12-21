require 'rubygems'
require 'dm-core'
require 'dm-validations' 
require 'dm-timestamps'
require 'dm-aggregates'

 
DataMapper.setup(:default, ENV['DATABASE_URL'] || 'sqlite3:db/gabd.sqlite3')

class Dilemma
  include DataMapper::Resource 
  
  has n, :suggestions
  
  property :id, String, :length => 280, 
    :key => true,
    :default => Proc.new {|r, p| r.text.sluggify } 
    
  property :text, String, :length => 140, :required => true, :unique => true,
    :messages => { 
      :presence => "You didn't write anything!", 
      :is_unique => "Someone has posted this dilemma before!"
    }
  property :by, String , :length => 50, :required => true,
    :messages => { 
      :presence => "Please enter your name"
    }
    
  property :date_created, DateTime, :default => DateTime.now 
     
    def add_evil_suggestion(text, by)      
      suggestions.new(:text => text, :by => by, :type => "e")                   
    end
    
    def add_good_suggestion(text, by)      
      suggestions.new(:text => text, :by => by, :type => "g")
    end
    def good_suggestions
      suggestions.all(:type => 'g')
    end
    def evil_suggestions
      suggestions.all(:type => 'e')
    end
    
    def Dilemma.latest
      Dilemma.all(:date_created => ((DateTime.now - 2)..DateTime.now))
    end 
end  

class Suggestion 
  
  include DataMapper::Resource 
  
  belongs_to :dilemma
  
  property :id , Serial
  
  property :text, String, :length => 140, :required => true,  
    :messages => { :presence => "You didn't write anything!" }
    
  property :dilemma_id, String, :length => 280  
  property :by, String , :length => 50, :required => true,
    :messages => { :presence => "Please enter your name"}  
    
  property :type, String,  :length => 1 ,   :format => lambda {|s| s == "g" or s == "e" }
  property :date_created, DateTime, :default => DateTime.now 
  validates_is_unique :text, :scope => :dilemma_id,    
    :message => "Someone already said that!"
end




#DataMapper.auto_migrate!

#Insert default values
#d.add_evil_suggestion("No!", "Peter")


#Helpers

#Sluggify
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



d = Dilemma.new(:text => "Should I have created this site?", :by => "Michael")
d.save

