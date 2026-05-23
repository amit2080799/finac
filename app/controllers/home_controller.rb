# frozen_string_literal: true

class HomeController < ApplicationController
  skip_before_action :authenticate_user!
  skip_authorization_check

  layout 'spa'

  def index; end
end
