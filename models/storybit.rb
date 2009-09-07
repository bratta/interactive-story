class Comment
  include MongoMapper::EmbeddedDocument
  
  # Not necessary, but useful
  key :name, String
  key :body, String
  
  # Again, not necessary, but useful
  validates_presence_of :name
  validates_presence_of :body  
end


class Storybit
  include MongoMapper::Document
  
  # We have many comments embedded in this document
  many :comments
  
  # Not necessary, but useful
  key :name, String
  key :body, String
  key :tags, Array
  
  # Again, not necessary, but useful
  validates_presence_of :name
  validates_presence_of :body
end