require 'test_helper'

class MicropostsInterfaceTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
  end

  test "micropost interface" do
    log_in_as(@user)  #ユーザーログイン
    get root_path     #ルートパスへ移動
    assert_select 'div.pagination'  #
    assert_select 'input[type=file]' #ルートパスに画像アップロードボタンがあるか確認
    #無効な送信
    #無効な送信の前後で投稿数が変化しない事を確認
    assert_no_difference 'Micropost.count' do
      post microposts_path, params: { micropost: { content: "" } }
    end
    assert_select 'div#error_explanation'
    #有効な送信
    #有効な送信の前後で投稿数が１変化する事を確認
    content = "This micropost really ties the room together"
    picture = fixture_file_upload('test/fixtures/rails.png', 'image/png') #ファイルをアップロードするメソッド
    assert_difference 'Micropost.count', 1 do
      post microposts_path, params: { micropost:
                                      { content: content,
                                        picture: picture } }
    end
    assert assigns(:micropost).picture? #画像が投稿されているか確認
    assert_redirected_to root_url #ルートパスへ移動
    follow_redirect!
    assert_match content, response.body #投稿がページにあるか確認
    #投稿を削除する
    assert_select 'a', text: 'delete'
    first_micropost = @user.microposts.paginate(page: 1).first
    assert_difference 'Micropost.count', -1 do
      delete micropost_path(first_micropost)
    end
    #違うユーザーのプロフィールにアクセス（削除リンクがない事を確認）
    get user_path(users(:archer)) #ログインユーザーと異なるユーザーのページへ行く
    assert_select 'a', text: 'delete', count: 0 #deleteリンクがない事を確認
  end

  #サイドバーでマイクロポストの投稿数表示のテスト
  test "micropost sidebar count" do
    log_in_as(@user)  #ユーザーログイン（michael）
    get root_path #ルートパスへ移動
    assert_match "#{@user.microposts.count} microposts", response.body #投稿数が正しく表示されている事を確認（複数形）
    #まだマイクロポストを投稿していないユーザー
    other_user = users(:malory) #投稿数０のユーザー
    log_in_as(other_user)       #投稿数０のユーザーでログイン
    get root_path               #ルートパスへ移動
    assert_match "0 microposts", response.body  #投稿数表示が正しい事を確認
    other_user.microposts.create!(content: "A micropost") #１つ目の投稿をする
    get root_path #ルートパスへ移動
    assert_match "1 micropost", response.body #投稿数表示が正しい事を確認（単数形）
  end
end
