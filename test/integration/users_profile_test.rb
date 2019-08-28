require 'test_helper'

class UsersProfileTest < ActionDispatch::IntegrationTest
  include ApplicationHelper #full_titleヘルパーが利用できる

  def setup
    @user = users(:michael)
  end

  #ユーザープロフィール画面のテスト
  test "profile display" do
    get user_path(@user) #ユーザーページを開く
    assert_template 'users/show' #showページが表示されている事を確認
    assert_select 'title', full_title(@user.name) #タイトル名がユーザー名になっている事を確認
    assert_select 'h1', text: @user.name #h1にユーザー名が表示されている事を確認
    assert_select 'h1>img.gravatar' #h1にgravatar画像が表示されている事を確認
    assert_match @user.microposts.count.to_s, response.body #マイクロポストの投稿数とHTMLの表示数が同じか
    assert_select 'div.pagination', count: 1
    @user.microposts.paginate(page: 1).each do |micropost|
      assert_match micropost.content, response.body
    end
  end
end
