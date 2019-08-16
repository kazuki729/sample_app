class PasswordResetsController < ApplicationController
  before_action :get_user, only: [:edit, :update]
  before_action :valid_user, only: [:edit, :update]
  before_action :check_expiration, only: [:edit, :update] #パスワードの有効期限が切れているかどうか確認

  def new
  end

  def create
    # email（password_reset）をキーにしてDBからユーザーを検索する
    @user = User.find_by(email: params[:password_reset][:email].downcase)
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      flash[:info] = "Email sent with password reset instructions"
      redirect_to root_url
    else
      flash.now[:danger] = "Email address not found"
      render "new"
    end
  end

  def edit
  end

  #パスワード再設定のUPDATEアクション
  def update
    if params[:user][:password].empty?  #新しいパスワードが空文字列でないか確認
      @user.errors.add(:password, :blank)
      render 'edit'
    elsif @user.update_attributes(user_params)  #新しいパスワードが正しい時
      log_in @user
      @user.update_attribute(:reset_digest, nil) #reset_digestをnilに設定
      flash[:success] = "Password has been reset."
      redirect_to @user
    else  #無効なパスワードの時
      render 'edit'
    end
  end

  private
    def user_params
      params.required(:user).permit(:password, :password_confirmation)
    end

    #以下、beforeフィルタ

    def get_user
      @user = User.find_by(email: params[:email])
    end

    #正しいユーザーかどうか確認する
    def valid_user
      unless (@user && @user.activated? && @user.authenticated?(:reset, params[:id]))
        redirect_to root_url
      end
    end

    #トークンが期限切れかどうか確認する
    def check_expiration
      if @user.password_reset_expired?
        flash[:danger] = "Password reset has expired."
        redirect_to new_password_reset_url
      end
    end
end
