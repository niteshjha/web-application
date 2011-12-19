class StudentsController < ApplicationController
  before_filter :authenticate_account!
  respond_to :json

  def create 
    school = School.find params[:id] 
    head :bad_request if school.nil?
    
    @student = Student.new params[:student]
    username = @student.generate_username
    email = params[:student].delete(:email) || "#{username}@drona.com"
    @student.school = school 
    password = school.zip_code

    unless username.blank?
      account = @student.build_account :username => username, :email => email,  
                                      :password => password, :password_confirmation => password
    end 
    @student.save ? respond_with(@student) : head(:bad_request)  
  end 

end
