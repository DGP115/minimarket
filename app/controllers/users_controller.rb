class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: %i[ profile_show profile_edit profile_update ]

  def profile_edit
    render "users/profile/edit"
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: "User not found."
  end

  def profile_show
    render "users/profile/show"
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: "User not found."
  end

  def profile_update
    if @user.update(userprofile_params)
      redirect_to edit_user_profile_path(@user)
      flash[:notice] = "Profile was successfully updated."
    else
      render "users/profile/edit", status: :unprocessable_entity
    end
  end

  private

  def userprofile_params
    params.expect(user: [ :name, :email, :profile_image ])
  end

  def set_user
    @user = User.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: "User not found."
  end
end
