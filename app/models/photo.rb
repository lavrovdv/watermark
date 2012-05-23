class Photo < ActiveRecord::Base
  # attr_accessible :title, :body
  attr_accessible  :photo1, :photo2
  has_attached_file :photo1 #, :processors => [:watermark_tool], :styles => { :thumb => '250x250>', :resized => { :geometry => '500x500>',  :watermark_path => '#{RAILS_ROOT}/public/images/watermark_tool.png', :position => 'Center' }}
  has_attached_file :photo2 #, :styles => { :medium => "300x300>", :thumb => "100x100>" }
end
