class StaticPagesController < ApplicationController
  def home
    if logged_in?
      #micropostのインスタンう変数
      @micropost = current_user.microposts.build
      #feedのインスタンス変数
      @feed_items = current_user.feed.paginate(page: params[:page])
    end
  end

  def help
  end

  def about
  end

  def contact
  end
end
