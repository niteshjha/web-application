class GradesController < ApplicationController
  respond_to :json
  before_filter :authenticate_account!

  def update
    grade = Grade.where(:yardstick_id => params[:id], :teacher_id => params[:teacher_id]).first
    head :bad_request if grade.nil?
    if grade.update_attribute :allotment, params[:grade][:allotment]
      render :json => { :status => "Updated!" }, :status => :ok
    else
      render :json => { :status => "Oops" }, :status => :bad_request
    end
  end

end
