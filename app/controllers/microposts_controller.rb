class MicropostsController < ApplicationController
  #Micropostsコントローラの各アクションに認可を追加する
  #Micropostsの作成や削除時にログイン状態であることを確認する
  before_action :logged_in_user, only: [:create, :destroy]
  #Micropostsの削除時に投稿ユーザー本人であることを確認する
  before_action :correct_user, only: :destroy

  #createアクション
  def create
    @micropost = current_user.microposts.build(micropost_params)
    if @micropost.save #saveに成功したら
      flash[:success] = "Micropost created!"  #メッセージ
      redirect_to root_url
    else #失敗したら
      @feed_items = []
      render 'static_pages/home' #home画面に移動
    end
  end

  #destroyアクション
  def destroy
    @micropost.destroy
    flash[:success] = "Micropost deleted"
    #redirect_to request.referrer || root_url  #destroyアクションを発行したURLに飛ぶ
    redirect_back(fallback_location: root_url)  #Rails5からサポート
  end

  private

    def micropost_params
      params.require(:micropost).permit(:content, :picture)
    end

    def correct_user
      #取得したmicropostのIDをキーにしてログインユーザーの投稿に対象の投稿が存在するか探す
      @micropost = current_user.microposts.find_by(id: params[:id])
      #ログインユーザーの投稿であれば、削除に進む。違う場合は、root_urlに戻って終了
      redirect_to root_url if @micropost.nil?
    end
end
