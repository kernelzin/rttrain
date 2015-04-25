class Train

  include Mongoid::Document

  field :name

  has_many :fonts

end
