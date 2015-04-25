class Font

  include Mongoid::Document

  field :name

  belongs_to :train

  has_many :pictures

end
