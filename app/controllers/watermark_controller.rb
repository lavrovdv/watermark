require 'RMagick'
class WatermarkController < ApplicationController

  def preview
    @photo = Photo.find(params[:id])
    #edit(@photo.id) unless File.exist? "#{Rails.root}/app/asserts/images/preview.jpg"
    image = Magick::Image.read(@photo.photo1.path).first

    @text = @text || "Watermark"
    @font_size = (image.columns / @text.size * 1.5).to_i
    @opacity = @opacity|| 0.25
    @position = @position || :bottom
  end

  def edit(id = nil)
    require "watermark_tool/watermark_tool"

    photo = Photo.find(params[:id] || id)
    text      = params[:text]              || "Watermark"
    font_size = params[:text_size].to_i    || 48
    opacity   = params[:text_opacity].to_f || 0.25
    position  = params[:position].to_sym   || :bottom
    type      = params[:type] || "text"

    watermark = WatermarkTool.new(photo.photo1.path,"#{Rails.root}/app/assets/images/preview.jpg")

    if type == "text"
      watermark.from_text(text, opacity, position)
    else
      watermark.from_file("#{Rails.root}/app/assets/images/watermark.png", position)
    end
    redirect_to "/watermark/#{photo.id}"
  end
end
