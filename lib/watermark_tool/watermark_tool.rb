require 'RMagick'
class WatermarkTool

  # константы позиций рисунка и угол поворота изображения
  POSITIONS = {
      left:       { gravity: Magick::WestGravity,    rotate: -90 },
      right:      { gravity: Magick::EastGravity,    rotate: -90 },
      top:        { gravity: Magick::NorthGravity,   rotate: nil },
      bottom:     { gravity: Magick::SouthGravity,   rotate: nil },
      diagonal:   { gravity: Magick::CenterGravity,  rotate: -45 }
  }

  def initialize(photo_path, result_path)
    @photo_path   = photo_path
    @result_path  = result_path
    @image  = Magick::Image.read(photo_path).first
  end

  def from_text(text, opacity, position, font_size = nil, width = nil, height = nil, height_ratio = 4)

    width   = width  || gravity(position).nil? ? @image.columns : @image.rows
    height  = height || (width/height_ratio).to_i
    mark    = Magick::Image.new(width, height) {self.background_color = 'none'}
    font_size = font_size || calculate_font_size(text, width, height)
    gc = Magick::Draw.new
    gc.annotate(mark, 0, 0, 0, 0, text) do
      self.gravity = Magick::CenterGravity
      self.pointsize = font_size
      self.font_family = "Times" # todo: добавить выбор шрифта
      self.fill = "white"
      self.stroke = "none"
    end

    # если требуется поворачиваем изображение
    mark.rotate!(rotate_deg(position)) unless rotate_deg(position).nil?
    @image = @image.watermark(mark, opacity, 0, gravity(position))

    write_result
  end

  def from_file(watermark_path, position, width = nil)
    width   = width  || gravity(position).nil? ? @image.columns : @image.rows
    src = Magick::Image.read(watermark_path).first
    src.resize_to_fit!(width)
    src.rotate!(rotate_deg(position)) unless rotate_deg(position).nil?
    @image = @image.composite(src, gravity(position), Magick::OverCompositeOp)
    write_result
  end

  def calculate_font_size(text, width, height, point_step = 10, border = 0)
    mark_temp = Magick::Image.new(width, height) {self.background_color = 'none'}
    temp_height, temp_width = 0, 0
    font_size = 8

    while temp_width < width - border and temp_height < height - border do
      gc = Magick::Draw.new
      gc.annotate(mark_temp, 0, 0, 0, 0, text) do
        self.gravity = Magick::CenterGravity
        self.pointsize = font_size
        self.font_family = "Times" # todo: добавить выбор шрифта
        self.fill = "white"
        self.stroke = "none"
      end

      metrics = gc.get_multiline_type_metrics(text)
      temp_height = metrics.height
      temp_width  = metrics.width
      font_size = font_size + point_step
    end

    font_size
  end

  private

  def write_result
    @image.write(@result_path)
  end

  def gravity(position)
    POSITIONS[position][:gravity]
  end

  def rotate_deg(position)
    POSITIONS[position][:rotate]
  end

end