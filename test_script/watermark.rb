require 'RMagick'

p "-f - file name" if ARGV.index('-h') or ARGV.index('-help')

file_name = ARGV[ARGV.index('-f') + 1] if ARGV.index('-f')
raise "no file name" unless file_name


mark = Magick::Image.new(500, 50) do
  self.background_color = 'none'
end
gc = Magick::Draw.new
gc.annotate(mark, 0, 0, 0, 0, "Image by RMagick") do
  self.gravity = Magick::CenterGravity
  self.pointsize = 48
  self.font_family = "Times"
  self.fill = "white"
  self.stroke = "none"
end
#mark.rotate!(-90)

image = Magick::Image.read(file_name).first
image = image.watermark(mark, 0.35, 0, Magick::SouthGravity)
time = Time.now
#image.write("result #{time.day}.#{time.month}.#{time.year}-#{time.hour}:#{time.min}:#{time.sec}.jpg")
image.resize_to_fit!(375, 375)
image.write("result.jpg")
p "Geometry: #{image.columns}x#{image.rows}"

# наложение изображение одного на другое
#dst = Magick::Image.read("plasma:fractal") {self.size = "128x128"}.first
#src = Magick::Image.read('tux.png').first
#result = dst.composite(src, Magick::CenterGravity, Magick::OverCompositeOp)
#result.write('composite2.gif')

# получение размера изображения
# image.columns image.rows

# Изменение размера изображения с сохранением
# image.resize_to_fit!(375, 375)


