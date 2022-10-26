require "test_helper"

class OrdersControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get orders_index_url
    assert_response :success
  end

  test "should get submit" do
    get orders_submit_url
    assert_response :success
  end
end
