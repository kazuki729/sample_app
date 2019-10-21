class UsersController < ApplicationController
  # コントローラ内の特定のアクションにのみbeforeアクションを適用【onlyオプション】
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy, :following, :followers]
  before_action :correct_user,   only: [:edit, :update]
  before_action :admin_user,     only: :destroy

  def show
    @user = User.find(params[:id])
    redirect_to root_url and return unless @user.activated?
    if params[:q] && params[:q].reject { |key, value| value.blank? }.present?
      @q = @user.microposts.ransack(microposts_search_params)
      @microposts = @q.result.paginate(page: params[:page])
    else
      @q = Micropost.none.ransack
      @microposts = @user.microposts.paginate(page: params[:page])
    end
    @url = user_path(@user)
  end

  def new
    @user = User.new
  end

  def create
    # @user = User.new(params[:user])    # 実装は終わっていないことに注意!
    @user = User.new(user_params)
    if @user.save
      # 保存の成功をここで扱う。
      log_in @user
      flash[:success] = "Wlecome to the sample App!"
      # "redirect_to @user" = "redirect_to user_url(@user)"
      redirect_to user_url(@user)
    else
      render 'new'
    end
  end

  def edit
    # ユーザー情報を編集するアクション
    # @user = User.find(params[:id]) ←correct_userで定義しているためコメント
  end

  def update
    # @user = User.find(params[:id]) ←correct_userで定義しているためコメント
    if @user.update_attributes(user_params)
      # 更新に成功した場合を扱う。
      flash[:success] = "Profile updated"
      redirect_to @user
    else
      render 'edit'
    end
  end

  # ユーザーのindexアクション
  def index
    # @users = User.all
    #@users = User.paginate(page: params[:page])
    #検索機能追加前
    #@users = User.where(activated: true).paginate(page: params[:page])
    #検索機能追加後
    if params[:q] && params[:q].reject { |key, value| value.blank? }.present?
      @q = User.ransack(search_params, activated_true: true)
      @title = "Search Result"
    else
      @q = User.ransack(activated_true: true)
      @title = "All users"
    end
    @users = @q.result.paginate(page: params[:page])
  end

  # destroyアクション
  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User deleted"
    redirect_to users_url
  end

  def create
    @user = User.new(user_params)
    if @user.save
      @user.send_activation_email
      # UserMailer.account_activation(@user).deliver_now
      flash[:info] = "Please check your email to ativate your account"
      redirect_to root_url
    else
      render 'new'
    end
  end

  #followingアクション
  def following
    @title = "Following"
    @user  = User.find(params[:id])
    @users = @user.following.paginate(page: params[:page])
    render 'show_follow'
  end

  #followerアクション
  def followers
    @title = "Followers"
    @user  = User.find(params[:id])
    @users = @user.followers.paginate(page: params[:page])
    render 'show_follow'
  end

  private

      def user_params
        # ここで許可されたパラメータのみユーザーは編集可能
        params.require(:user).permit(:name, :email, :password,
                                     :password_confirmation,
                                     :follow_notification)
      end

      # BEFOREアクション

      # 正しいユーザーかどうか確認
      def correct_user
        @user = User.find(params[:id])
        redirect_to(root_url) unless current_user?(@user)
      end

      # 管理者かどうか確認
      def admin_user
        redirect_to(root_url) unless current_user.admin
      end

      #検索
      #:name_contは検索にヒットしたユーザー一覧
      def search_params
        params.require(:q).permit(:name_cont)
      end
end
