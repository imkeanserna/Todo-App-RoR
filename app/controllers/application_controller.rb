class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?
  protect_from_forgery with: :exception

  private

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name])
    devise_parameter_sanitizer.permit(:account_update, keys: [:first_name, :last_name])
  end

  def handle_service_result(result, success_path = nil, &block)
    if result.success?
      if block_given?
        yield result.data
      elsif success_path
        redirect_to success_path, notice: "Operation completed successfully"
      end
    else
      if result.errors.respond_to?(:full_messages)
        flash.now[:alert] = result.errors.full_messages.join(", ")
      else
        flash.now[:alert] = result.errors || "An error occurred"
      end
      render :new if action_name == "create"
      render :edit if action_name == "update"
    end
  end
end
