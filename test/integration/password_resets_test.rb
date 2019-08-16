require 'test_helper'

class PasswordResetsTest < ActionDispatch::IntegrationTest

  def setup
    ActionMailer::Base.deliveries.clear
    @user = users(:michael)
  end

  test "password resets" do
    get new_password_reset_path #パスワード再設定ページへアクセス
    assert_template 'password_resets/new' #Forgot password画面が表示されているか確認
    #メールアドレスが無効な場合をテスト
    post password_resets_path, params: { password_reset: {email: ""}} #空文字のメールアドレスを入れて送信
    assert_not flash.empty? #エラーメッセージが表示されている事を確認
    assert_template 'password_resets/new' #Forgot password画面が表示されている事を確認
    #メールアドレスが有効な場合をテスト
    post password_resets_path, params: { password_reset: { email: @user.email } } #正しいメールアドレスを入れて送信
    assert_not_equal @user.reset_digest, @user.reload.reset_digest #メールアドレス送信の前後でreset_digestが異なることを確認
    assert_equal 1, ActionMailer::Base.deliveries.size #メールが1件送信された事を確認
    assert_not flash.empty? #エラーメッセージがない事を確認
    assert_redirected_to root_url #ルートURLに遷移された事を確認
    #パスワード再設定フォームのテスト
    user = assigns(:user) #直前に作られたインスタンス変数(user)を取得する
    #メールアドレスが無効な場合をテスト
    get edit_password_reset_path(user.reset_token, email: "") #パスワード再設定画面に空文字のメールアドレスを送信
    assert_redirected_to root_url #ルートURLに遷移された事を確認
    #無効なユーザーをテスト
    user.toggle!(:activated)  #認証されていないユーザーを生成
    get edit_password_reset_path(user.reset_token, email: user.email) #パスワード再設定画面に未認証のユーザーを送信
    assert_redirected_to root_url #ルートURLに遷移された事を確認
    user.toggle!(:activated) #属性を認証状態に戻しておく
    #メールアドレスが有効で、トークンが無効
    get edit_password_reset_path('wrong token', email: user.email) #トークンが無効な文字列な場合
    assert_redirected_to root_url #ルートURLに遷移された事を確認
    #メールアドレスもトークンも有効
    get edit_password_reset_path(user.reset_token, email: user.email) #正しいトークン、メールアドレスで送信
    assert_template 'password_resets/edit'  #パスワード再設定画面が表示されている事を確認
    assert_select "input[name=email][type=hidden][value=?]", user.email #隠し属性にメールアドレスがセットされている事を確認
    #無効なパスワードとパスワード確認
    patch password_reset_path(user.reset_token),
          params: { email: user.email,
                    user: { password:  "foobaz",
                            password_confirmation: "barquux"}}
    assert_select 'div#error_explanation' #エラー内容が表示されている事を確認
    #有効なパスワードとパスワード確認
    patch password_reset_path(user.reset_token),
          params: { email: user.email,
                    user: { password: "foobaz",
                            password_confirmation: "foobaz"}}
    assert_nil user.reload.reset_digest #パスワード再設定成功後にreset_digestがnilになっている事を確認
    assert is_logged_in?    #ログイン状態である事を確認
    assert_not flash.empty? #エラーメッセージがない事を確認
    assert_redirected_to user #ユーザーページへ遷移している事を確認
  end

  test "expired token" do
    get new_password_reset_path #Forgot password画面へアクセスする
    post password_resets_path,
         params: { password_reset: { email: @user.email } } #メールアドレスを入れて送信
    @user = assigns(:user) #直前のインスタンス変数（user）を取得
    @user.update_attribute(:reset_sent_at, 3.hours.ago) #パスワード再設定の発行時間を３時間前に変更
    patch password_reset_path(@user.reset_token),
          params: { email: @user.email,
                    user: { password:              "foobar",
                            password_confirmation: "foobar" } }
    assert_response :redirect #アクションが返ってきている事を確認
    follow_redirect! #POSTリクエストを送信した結果を見て、指定されたリダイレクト先に移動するメソッド
    assert_match /expired/i, response.body
  end
end
