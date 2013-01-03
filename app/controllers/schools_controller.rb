class SchoolsController < ApplicationController
  include GeneralQueries
  before_filter :authenticate_account!
  respond_to :json 

  def add_students
    @school = School.find params[:id]
    head :bad_request if @school.nil?

    status = :ok
    klass = params[:klass].to_i

    params[:names].each do |i, name|
      next if name.blank?
      student = Student.new :name => name
      username = create_username_for student, :student
      next if username.blank? 

      email = "#{username}@drona.com"
      student.school = @school
      password = @school.zip_code
      student.klass = klass

      account = student.build_account :username => username, :email => email,
                                      :password => password, 
                                      :password_confirmation => password
      status = student.save ? :ok : :bad_request
      break if status == :bad_request
    end
    status == :ok ? respond_with(@school) : head(:bad_request)
  end

  def create 
    email = params[:school].delete :email # email is part of Account model 
    @school = School.new params[:school] 
    username = create_username_for @school, :school 
    email = email || "#{username}@drona.com"
    zip = @school.zip_code

    @school.build_account :email => email, :username => username, 
                          :password => zip, :password_confirmation => zip

    @school.save ? respond_with(@school) : head(:bad_request) 
  end 

  def show 
    @school = School.find params[:id]
    head :bad_request if @school.nil?
  end 

  def update 
    school = School.find params[:id] 
    status = :ok

    unless school.nil? 
      active = params[:account][:active] == 'true' ? true : false 
      status = school.update_attributes(params[:school]) ? :ok : :bad_request
      unless status == :bad_request
        status = school.account.update_attribute(:active, active) ? :ok : :bad_request
      end
    else 
      status = :bad_request 
    end 

    render(:json => { :status => "Done" }, :status => status) if status == :ok
    render(:json => { :status => "Update failed!" }, :status => status) if status == :bad_request
  end 

  def list 
    @schools = School.order(:name)

    n = @schools.count 
    @per_pg, @last_pg = pagination_layout_details n
    pg = params[:page].nil? ? 1 : params[:page].to_i
    @schools = @schools.page(pg).per(@per_pg)
  end 

=begin
  def unassigned_students 
    @students = Student.where(:school_id => params[:id], :sektion_id => nil).order(:first_name)
    @who_wants_to_know = current_account.nil? ? :guest : current_account.role
  end 
=end

  def sektions 
    @sektions = Sektion.where(:school_id => params[:id]).order(:klass).order(:name)
  end 

  def upload_student_list
    @school = School.find params[:id]

    sektion = @school.sektions.build :klass => params[:excel][:klass].to_i, :name => params[:excel][:sektion]
    if sektion.save
      @school.xls = params[:excel][:xls]
      @school.save
      sektion.save # trigger student_roster_pdf generation
      render :json => { :status => :uploaded }, :status => :ok
    else
      render :json => { :status => :failed }, :status => :bad_request
    end
  end

end
