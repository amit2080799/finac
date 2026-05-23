# frozen_string_literal: true

require 'test_helper'

class HomeControllerTest < ActionDispatch::IntegrationTest
  test 'renders spa shell' do
    get root_url
    assert_response :success
    assert_select '#root'
  end
end
