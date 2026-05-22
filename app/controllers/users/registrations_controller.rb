class Users::RegistrationsController < Devise::RegistrationsController
  def create
    org = Organisation.new(name: params.dig(:user, :organisation_name))

    build_resource(sign_up_params)
    resource.role = :super_admin

    resource_saved = false
    ActsAsTenant.without_tenant do
      ActiveRecord::Base.transaction do
        if org.save
          resource.organisation = org
          resource.skip_confirmation! if Rails.env.development?
          resource_saved = resource.save
        else
          org.errors.each { |e| resource.errors.add(:base, e.full_message) }
        end
        raise ActiveRecord::Rollback unless resource_saved
      end
    end

    if resource_saved
      set_flash_message! :notice, :signed_up
      sign_up(resource_name, resource)
      respond_with resource, location: after_sign_up_path_for(resource)
    else
      clean_up_passwords resource
      set_minimum_password_length
      respond_with resource
    end
  end

  protected

  def after_sign_up_path_for(_resource)
    setup_details_path
  end
end
