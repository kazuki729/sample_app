require 'test_helper'

class SiteLayoutTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end

  # URLのルートが正しく設定されているかを確認するテストコード
  test "layout links" do
    get root_path
    assert_template 'static_pages/home'
    assert_select "a[href=?]", root_path, count: 2
    assert_select "a[href=?]", help_path
    assert_select "a[href=?]", about_path
    assert_select "a[href=?]", contact_path
    get contact_path
    assert_select "title", full_title("Contact")

    get signup_path
      assert_select "title", full_title("Sign up")
    end

    def setup
      @user = users(:michael)
    end

    test "layout links when logged in" do
      log_in_as(@user)
      get root_path
      assert_template 'static_pages/home'
      assert_select "a[href=?]", users_path
      assert_select "a[href=?]", user_path(@user)
      assert_select "a[href=?]", edit_user_path(@user)
      assert_select "a[href=?]", logout_path
    end

    #Homeページの統計情報に対するテスト
    test "count relationships" do
      log_in_as(@user)
      get root_path
      assert_match @user.active_relationships.count.to_s, response.body
      assert_match @user.passive_relationships.count.to_s, response.body
    end
end
