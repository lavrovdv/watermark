class CaptchaController < ApplicationController
  include SimpleCaptcha::ControllerHelpers
  def index
  end

  def create
    if simple_captcha_valid?
      flash[:notice] = "valid"
      redirect_to :action=>'index'
    else
      flash[:alert] = "not valid"
      redirect_to :action=>'index'
    end
  end
end
