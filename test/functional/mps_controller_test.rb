require File.dirname(__FILE__) + '/../test_helper'
require 'mps_controller'

# Re-raise errors caught by the controller.
class MpsController; def rescue_action(e) raise e end; end

class MpsControllerTest < Test::Unit::TestCase
  fixtures :mps

  def setup
    @controller = MpsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:mps)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_mp
    old_count = Mp.count
    post :create, :mp => { }
    assert_equal old_count+1, Mp.count
    
    assert_redirected_to mp_path(assigns(:mp))
  end

  def test_should_show_mp
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_mp
    put :update, :id => 1, :mp => { }
    assert_redirected_to mp_path(assigns(:mp))
  end
  
  def test_should_destroy_mp
    old_count = Mp.count
    delete :destroy, :id => 1
    assert_equal old_count-1, Mp.count
    
    assert_redirected_to mps_path
  end
end
