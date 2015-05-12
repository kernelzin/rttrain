class Char

  include Mongoid::Document

  field :char
  field :x1, type: Integer
  field :x2, type: Integer
  field :y1, type: Integer
  field :y2, type: Integer
  field :fail, default: false

  embedded_in :charctertable

  # validates_uniqueness_of :x1, :x2, :y1, :y2, :scope => :box_id

  def as_json(options = {})
    options.merge(id: id.to_s, char: char, x1: x1, y1: y1, x2: x2, y2: y2, fail: fail)
  end

end
