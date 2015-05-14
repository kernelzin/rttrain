class Train

  include Mongoid::Document

  field :name

  has_many :fonts

  accepts_nested_attributes_for :fonts, allow_destroy: true

  def create_font_properties
    File.open "/tmp/#{name}/font_properties", 'w' do |file|
      fonts.each do |f|
        file.puts "#{f.properties} "
      end
    end
  end

end
