require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def setup
    # 全てのテスト内でこのインスタンス変数が使用可能
    @user = User.new(name: "Example User", email: "user@example.com",
                     password: "foobar", password_confirmation: "foobar")
  end

  test "should be valid" do
    assert @user.valid?
  end
  # 「存在性(Presence)」の検証
  # nameについて
  test "name should be present" do
    # 空白文字列をセット
    @user.name = "     "
    # Userオブジェクトが有効でなくなった事を確認
    assert_not @user.valid?
  end
  # emailについて
  test "email should be present" do
    @user.email = "     "
    assert_not @user.valid?
  end

  # 文字列の長さ制限
  # nameについて
  test "name should not be too long" do
    @user.name = "a" * 51
    assert_not @user.valid?
  end
  # emailについて
  test "email should not be too long" do
    @user.email = "a" * 244 + "@example.com"
    assert_not @user.valid?
  end

  # メールフォーマットの検証
  # 有効なメールアドレス
  test "email validation should accept valid addresses" do
    valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org
                         first.last@foo.jp alice+bob@baz.cn]
    valid_addresses.each do |valid_address|
      @user.email = valid_address
      assert @user.valid?, "#{valid_address.inspect} should be valid"
    end
  end
  # 無効なメールアドレス
  test "email validation should reject invalid addresses" do
    invalid_addresses = %w[user@example,com user_at_foo.org user.name@example.
                          foo@bar_baz.com foo@bar+baz.com foo@bar..com]
    invalid_addresses.each do |invalid_address|
      @user.email = invalid_address
      assert_not @user.valid?, "#{invalid_address.inspect} should be invalid"
    end
  end
  # 重複するメールアドレス拒否のテスト
  test "email addresses should be unique" do
    duplicate_user = @user.dup
    duplicate_user.email = @user.email.upcase
    @user.save
    assert_not duplicate_user.valid?
  end

  # メールアドレスの小文字化に対するテスト
  test "email addresses should be saved as lower-case" do
    mixed_case_email = "Foo@ExAMPle.CoM"
    @user.email = mixed_case_email
    @user.save
    assert_equal mixed_case_email.downcase, @user.reload.email
  end

  # パスワードが空でないことをテストする
  test "password should be present (nonblank)" do
    @user.password = @user.password_confirmation = " " * 6
    assert_not @user.valid?
  end

  # パスワードの最小文字数をテストする
  test "password should have a minimum length" do
    @user.password = @user.password_confirmation = "a" * 5
    assert_not @user.valid?
  end

  # ダイジェストが存在しない場合のauthenticated?のテスト
  test "authenticated? should return false for a user with nil digest" do
    assert_not @user.authenticated?(:remember, '')
  end

  #destroy: :dependentのテスト
  test "associated microposts should be destroyed" do
    @user.save #ユーザーをセーブする
    @user.microposts.create!(content: "Lorem ipsum") #ユーザーに紐づいた投稿をセーブする
    assert_difference 'Micropost.count', -1 do #マイクロポストの数が１つ減っているかどうか
      @user.destroy
    end
  end
end
