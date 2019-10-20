# Railsの全コントローラの親クラス
class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  # ここでリードしたモジュールは全コントローラで使用可
  include SessionsHelper

  private

    #ユーザーのログインを確認する
    #UserコントローラとMicropostコントローラで使用するためapplicationファイルに記述
    def logged_in_user
      unless logged_in? #sessionヘルパーの命令を実行（ログインの有無）
        store_location  #ユーザーがいた場所を保持しておく（ログイン後に元の場所にリダイレクトするため）
        flash[:danger] = "Please log in." #メッセージ
        redirect_to login_url #ログインURLに移動
      end
    end

    def microposts_search_params
      params.require(:q).permit(:content_cont)
    end
end
