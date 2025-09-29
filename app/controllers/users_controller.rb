class UsersController < ApplicationController
  before_action :authenticate_user!

  def profile_edit
    @user = User.find(params[:id])
    render "users/profile/edit"
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: "User not found."
  end

  def profile_update
    @user = User.find(params[:id])
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
end
