class Font

  include Mongoid::Document

  field :name

  field :italic,  type: Boolean, default: false
  field :bold,    type: Boolean, default: false
  field :fixed,   type: Boolean, default: false
  field :serif,   type: Boolean, default: false
  field :fraktur, type: Boolean, default: false

  belongs_to :train

  has_many :pictures


end
