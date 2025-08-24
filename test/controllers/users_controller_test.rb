require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:player_one)
    @player2 = users(:player_two)
  end

  test "should get login form" do
    get login_path
    assert_response :success
    assert_select "form[action=?]", login_path
    assert_select "input[name='user[username]']"
  end

  test "should login with existing user" do
    post login_path, params: { user: { username: @user.username } }
    assert_redirected_to dashboard_path
    assert_equal @user.id, session[:user_id]
    assert_equal "Successfully logged in as existing user #{@user.username}!", flash[:success]
  end

  test "should create new user on login with new username" do
    assert_difference('User.count') do
      post login_path, params: { user: { username: "new_test_user" } }
    end
    new_user = User.find_by(username: "new_test_user")
    assert_not_nil new_user
    assert_equal new_user.id, session[:user_id]
    assert_redirected_to dashboard_path
    assert_equal "Successfully created new user new_test_user with ID #{new_user.id}", flash[:success]
  end

  test "should not login without username" do
    post login_path, params: { user: { username: "" } }
    assert_redirected_to login_path
    assert_equal "Username is required.", flash[:error]
  end

  test "should logout" do
    login_as(@user)
    delete logout_path
    assert_nil session[:user_id]
    assert_redirected_to root_path
    assert_equal "You have logged out!", flash[:success]
  end

  test "should get current user" do
    login_as(@user)
    get current_user_path
    assert_response :success
  end

  test "should return not found for current user when not logged in" do
    get current_user_path
    assert_response :not_found
  end

  test "should switch player" do
    login_as(@user)
    post switch_player_path, params: { next_player_id: @player2.id }
    assert_redirected_to dashboard_path
    assert_equal @player2.id, session[:user_id]
    assert_equal "Switched to #{@player2.username}'s turn", flash[:notice]
  end

  test "should handle invalid player switch" do
    login_as(@user)
    post switch_player_path, params: { next_player_id: -1 }
    assert_redirected_to dashboard_path
    assert_equal "Could not switch players", flash[:alert]
  end

  test "should get user stats" do
    # We already have fixtures with games for player_one
    login_as(@user)
    get stats_user_path(@user)
    assert_response :success
    assert_not_nil assigns(:user)
    assert_not_nil assigns(:games_played)
    assert_not_nil assigns(:win_rate)
    assert_not_nil assigns(:average_guesses)
    assert_not_nil assigns(:best_game_guesses)
  end

  test "should get index" do
    login_as(@user)
    get users_path
    assert_response :success
    assert_not_nil assigns(:users)
  end

  test "should show user" do
    login_as(@user)
    get user_path(@user)
    assert_response :success
  end

  test "should return not found for invalid user" do
    login_as(@user)
    get user_path(-1)
    assert_response :not_found
  end

  private

  def login_as(user)
    post login_path, params: { user: { username: user.username } }
  end
end
