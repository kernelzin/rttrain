module ApplicationHelper

  def link_image(f)
    if f.object.data
      f.object.data.thumb
    else
      "#{}"
    end
  end

end
