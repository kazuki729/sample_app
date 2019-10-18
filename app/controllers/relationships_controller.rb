class RelationshipsController < ApplicationController
  before_action :logged_in_user

  def create
    #followボタンが押されたときのアクション
    @user = User.find(params[:followed_id])  #送られてきたIDを取得
    current_user.follow(@user)  #ログインユーザーが送られてきたユーザーIDをフォローする
    #redirect_to user  #フォローされたユーザーのプロフィールを表示
    #RelationshipsコントローラでAjaxリクエストに対応する
    respond_to do |format|
      format.html { redirect_to @user }
      format.js
    end
  end

  def destroy
    @user = Relationship.find(params[:id]).followed  #Relationshipの中から送られてきたIDを検索
    current_user.unfollow(@user)  #見つかったユーザーをunfollowする
    #redirect_to user  #unfollowされたユーザーのプロフィールを表示
    #RelationshipsコントローラでAjaxリクエストに対応する
    respond_to do |format|
      format.html { redirect_to @user }
      format.js
    end
  end
end
