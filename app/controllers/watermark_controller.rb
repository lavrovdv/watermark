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
    @temp ="temp"
    # константы позиций рисунка и угол поворота изображения
    positions = {
        left:     [Magick::WestGravity, -90],
        right:    [Magick::EastGravity, -90],
        top:      [Magick::NorthGravity, nil],
        bottom:   [Magick::SouthGravity, nil],
        diagonal: [Magick::CenterGravity, -45]
    }

    @photo = Photo.find(params[:id] || id)
    @text      = params[:text]              || "Watermark"
    #@font_size = params[:text_size].to_i    || 48
    @opacity   = params[:text_opacity].to_f || 0.25
    @position  = params[:position].to_sym   || :bottom
    @gravity   = positions[@position][0]
    @rotate    = positions[@position][1]
    @type      = params[:type] || "text"
    #font_size = @font_size

    image = Magick::Image.read(@photo.photo1.path).first
    width = @rotate.nil? ? image.columns : image.rows

    if @type == "text"
      font_size = (width / @text.size * 1.5).to_i

      # Создание поля изображения водяного знака и добавление текста
      mark = Magick::Image.new(width, (width/4).to_i) do
        self.background_color = 'none'
      end
      gc = Magick::Draw.new
      gc.annotate(mark, 0, 0, 0, 0, @text) do
        self.gravity = Magick::CenterGravity
        self.pointsize = font_size
        self.font_family = "Times"
        self.fill = "white"
        self.stroke = "none"
      end

      # если требуется поворачиваем изображение
      mark.rotate!(@rotate) unless @rotate.nil?
      image = image.watermark(mark, @opacity, 0, @gravity)

    else
      src = Magick::Image.read("#{Rails.root}/app/assets/images/watermark.png").first
      src.resize_to_fit!(width)
      src.rotate!(@rotate) unless @rotate.nil?
      image = image.composite(src, @gravity, Magick::OverCompositeOp)
    end

    image.write("#{Rails.root}/app/assets/images/preview.jpg")
    redirect_to "/watermark/#{@photo.id}"
  end
end
