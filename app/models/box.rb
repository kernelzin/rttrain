class Box
  include Mongoid::Document

  field :name

  embedded_in :picture

  belongs_to :font

  embeds_many :chars, as: :charctertable

  def as_json(options)
    options.merge(name: name, pic: pic, chars: chars.as_json)
  end

  def from_file(file)
    ch = []
    f = File.open(file).read
    f.each_line { |c| ch << c.split(" ") }
    ch.each{ |c| chars.create(char: c[0], x1: c[1], y1: c[2], x2: c[3], y2: c[4])}
  end

end
