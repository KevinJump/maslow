require 'test_helper'

class UserTest < ActiveModel::TestCase

  context "attr_accessible" do
    should "not allow mass assignment of permissions" do
      user = User.create!(permissions: ['signin'])
      assert_nil user.reload.permissions
    end
  end

  context "a normal user" do
    should "just be a viewer" do
      user = create(:user)
      assert user.viewer?
      refute user.editor?
      refute user.admin?
    end
  end

  context "an editor" do
    should "be a viewer as well" do
      editor = create(:editor)
      assert editor.viewer?
      assert editor.editor?
      refute editor.admin?
    end
  end

  context "an admin" do
    should "be both a viewer and an editor" do
      admin = create(:admin)
      assert admin.viewer?
      assert admin.editor?
      assert admin.admin?
    end
  end

  context "toggle bookmarks" do
    should "update the users bookmarked needs" do
      user = create(:user)

      user.toggle_bookmark(10001)
      assert_equal [10001], user.bookmarks

      user.toggle_bookmark(10002)
      assert_equal [10001, 10002], user.bookmarks

      user.toggle_bookmark(10001)
      assert_equal [10002], user.bookmarks
    end

    should "not accept an invalid number as a need id" do
      user = create(:user)

      user.toggle_bookmark(0)
      assert_equal [], user.bookmarks

      user.toggle_bookmark(-1)
      assert_equal [], user.bookmarks
    end
  end
end
