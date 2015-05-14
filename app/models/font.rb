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

  accepts_nested_attributes_for :pictures, allow_destroy: true

  def properties
    result = [italic, bold, fixed, serif, fraktur].map do |pp|
      pp ? 1 : 0
    end
    return "#{name} #{result.to_s.delete ",[]" }"
  end


end
