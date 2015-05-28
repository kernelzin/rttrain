class Box
  require 'open3'

  include Mongoid::Document

  field :tr_log, type: String

  belongs_to :picture

  embeds_many :chars, as: :charctertable

  after_create :from_file

  delegate :my_name, :download_pic, :path, :filename, :fullpath, :to_tmp, to: :picture

  def box_name
    "#{path}#{my_name}.box"
  end

  def as_json(options = {})
    options.merge(id: id.to_s, chars: chars.as_json)
  end

  def from_file
    file = box_name
    File.open(file).read.each_line do |l|
      c, x1, y1, x2,y2 = l.split(' ')
      chars.find_or_create_by(char: c, x1: x1, y1: y1, x2: x2, y2: y2)
    end
  end

  def to_file
    File.open box_name, 'w' do |file|
      chars.each do |c|
        file.puts "#{c.char} #{c.x1} #{c.y1} #{c.x2} #{c.y2} 0"
      end
    end
  end

  def to_tr
    to_file
    file = "/#{path}#{my_name}"
    to_tmp
    stdin, stdout, stderr, wait_thread = Open3.popen3("tesseract #{path}#{filename} #{file} box.train.stderr")
    c = stderr.gets(nil)
    stderr.close()
    update_attributes(tr_log: c)
    c = c.scan(/\((\d+),(\d*)\),\((\d+),(\d+)\)/)
    p c
    if c.is_a?(Array)
      c.each do |cc|
        p chars.where(:x1 => cc[0].to_i,
                      :y1 => cc[1].to_i,
                      :x2 => cc[2].to_i,
                      :y2 => cc[3].to_i).first.update_attributes(fail: true)
      end
    else
      c
    end
  end

  def has_tr
    if File.exist?("#{path}#{my_name}.tr")
      return true
    end
  end

  def tr_fail
    if tr_log
      c = tr_log.scan(/\b(FAILURE!)/).count
      if c > 0
        return c
      else
        return false
      end
    end
  end

end
