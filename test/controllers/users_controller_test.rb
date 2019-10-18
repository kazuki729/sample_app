require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
    @other_user = users(:archer)
    @non_activated_user = users(:non_activated)
  end

  # indexアクションのリダイレクトをテストする
  test "should redirect index when not logged in" do
    get users_path
    assert_redirected_to login_url
  end

  test "should get new" do
    get signup_path
    assert_response :success
  end

  test "should redirect edit when not logged in" do
    get edit_user_path(@user)
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "should redirect update when not logged in" do
    patch user_path(@user), params: {user: { name: @user.name,
                                             email: @user.email }}
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  # 間違ったユーザーが編集しようとしたときのテスト
  test "should redirect edit when logged in as wrong user" do
    log_in_as(@other_user)
    get edit_user_path(@user)
    assert flash.empty?
    assert_redirected_to root_url
  end

  test "should redirect update when logged in as wrong user" do
    log_in_as(@other_user)
    patch user_path(@user), params: {user: { name: @user.name,
                                             email: @user.email }}
    assert flash.empty?
    assert_redirected_to root_url
  end

  # admin属性の変更が禁止されていることをテストする【このテストは怪しい？演習10.4.1】
  test "should not allow the admin attribute to be edited via the web" do
    log_in_as(@other_user)
    assert_not @other_user.admin?
    patch user_path(@other_user), params: {
                                    user: { password:              @other_user.password,
                                            password_confirmation: @other_user.password_confirmation,
                                            admin: true } }
    assert_not @other_user.reload.admin?
  end

  # 管理者権限の制御をアクションレベルでテストする
  test "should redirect destroy when not logged in" do
    assert_no_difference 'User.count' do
      delete user_path(@user)
    end
    assert_redirected_to login_url
  end

  test "should redirect destroy when logged in as a non-admin" do
    log_in_as(@other_user)
    assert_no_difference 'User.count' do
      delete user_path(@user)
    end
    assert_redirected_to root_url
  end

  test "should not allow the not activated attribute" do
    log_in_as (@non_activated_user) #非有効化ユーザーでログイン
    assert_not @non_activated_user.activated? #有効化でないことを検証
    get users_path  #/usersを取得
    assert_select "a[huref=?]", user_path(@non_activated_user), count: 0  #非有効化ユーザーが表示されていない事を確認
    get user_path(@non_activated_user)  #非有効化ユーザーIDのページを取得
    assert_redirected_to root_url #ルートURLにリダイレクトされればTRUE
  end

  #フォローページの認可をテストする
  test "should redirect following when not logged in" do
    get following_user_path(@user)  #ログインしていない場合、
    assert_redirected_to login_url  #ログインリンクへ移動
  end

  #フォロワーページの認可をテストする
  test "should redirect followers when not logged in" do
    get followers_user_path(@user)  #ログインしていない場合、
    assert_redirected_to login_url  #ログインリンクへ移動
  end
end
