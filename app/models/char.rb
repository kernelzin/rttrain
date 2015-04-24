class Char

  include Mongoid::Document

  field :char
  field :x1
  field :x2
  field :y1
  field :y2

  embedded_in :charctertable

  def as_json(options = {})
    options.merge(char: char, x1: x1, y1: y1, x2: x2, y2: y2)
  end
end
