class Box
  include Mongoid::Document

  belongs_to :picture

  embeds_many :chars, as: :charctertable
  # mount_uploader :data, ImageUploader
  after_save :picturize


  def picturize
    from_picture(picture)
  end

  def as_json(options = {})
    options.merge(name: name, pic: pic, chars: chars.as_json)
  end

  def from_picture(picture, language = "nota")
    p picture.data.file.filename
    `tesseract #{picture.data.file.file} #{picture.data.file.file[0..-5]} -l #{language} batch.nochop makebox`
  end

  def from_file(file)
    ch = []
    f = File.open(file).read
    f.each_line { |c| ch << c.split(" ") }
    ch.each{ |c| chars.create(char: c[0], x1: c[1], y1: c[2], x2: c[3], y2: c[4])}
  end

end
