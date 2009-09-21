require 'rubygems'
require 'dm-core'
require 'dm-timestamps'
require 'dm-aggregates'
 
DataMapper.setup(:default, ENV['DATABASE_URL'] || 'sqlite3://db/budget.sqlite3')

class Dillema
  include DataMapper::Resource
 
  property :text, String, :length => 140
  property :slug, String, :length => 280
end  