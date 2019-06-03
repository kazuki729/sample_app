# Railsの全コントローラの親クラス
class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  # ここでリードしたモジュールは全コントローラで使用可
  include SessionsHelper

  def hello
    render html: "hello, world!"
  end
end
