# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include CanCan::ControllerAdditions

  before_action :authenticate_user!, unless: :public_request?
  check_authorization unless: :skip_authorization?

  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |format|
      format.html { redirect_to root_path, alert: exception.message }
      format.json { render json: { error: exception.message }, status: :forbidden }
    end
  end

  def current_ability
    @current_ability ||= Ability.new(current_user)
  end

  private

  def public_request?
    devise_controller? || controller_name == 'turbo_devise' || controller_name == 'home'
  end

  def skip_authorization?
    public_request? || controller_path.start_with?('api/v1/sessions')
  end
end
