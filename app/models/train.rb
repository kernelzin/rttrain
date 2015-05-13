class Train

  include Mongoid::Document

  field :name

  has_many :fonts

  accepts_nested_attributes_for :fonts, allow_destroy: true

end
