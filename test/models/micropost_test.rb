require 'test_helper'

class MicropostTest < ActiveSupport::TestCase

  def setup
    @user = users(:michael)
    # このコードは慣習的に正しくない
    # @micropost = Micropost.new(content: "Lorem ipsum", user_id: @user.id)
    @micropost = @user.microposts.build(content: "Lorem ipsum")
  end

  #user_idがある場合はvalidがtrueになるかどうかテスト
  test "should be valid" do
    assert @micropost.valid?
  end

  #user_idがnilの時はvalidがfalseになるかどうかテスト
  test "user id should be present" do
    @micropost.user_id = nil
    assert_not @micropost.valid?
  end

  #空文字列は無効となるかどうかテスト（valid? = false）
  test "content should be present" do
    @micropost.content = "    " #空文字列生成
    assert_not @micropost.valid?
  end

  #contentが140文字以上で無効となるかテスト（valid? = false）
  test "content should be at most 140 characters" do
    @micropost.content = "a" * 141 #141文字の文字列生成
    assert_not @micropost.valid?
  end

  #マイクロポストの順序付けをテストする
  test "order should be most recent first" do
    assert_equal microposts(:most_recent), Micropost.first
  end
end
