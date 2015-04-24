class Box
  include Mongoid::Document

  field :name
  field :pic
  embeds_many :chars, as: :charctertable

  def as_json(options)
    options.merge(name: name, pic: pic, chars: chars.as_json)
  end

  class<< self
    def from_file(file)
      chars = []
      box = Box.new
      box.save
      f = File.open(file).read
      f.each_line { |c| chars << c.split(" ") }
      chars.each{ |c| box.chars.create(char: c[0], x1: c[1], y1: c[2], x2: c[3], y2: c[4])}
    end
  end

end
