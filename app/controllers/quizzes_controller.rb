class QuizzesController < ApplicationController
  before_filter :authenticate_account!
  respond_to :json, :xml

  def assign_to
    quiz = Quiz.where(:atm_key => params[:id]).first 
    head :bad_request if quiz.nil?
    teacher = quiz.teacher 

    #students = Student.where(:id => params[:checked].keys)
    #response = quiz.assign_to students
    students = params[:checked].keys   # we need just the IDs
    Delayed::Job.enqueue BuildTestpaper.new(quiz.id, students), :priority => 0, :run_at => Time.zone.now
    #render :json => response, :status => (response[:manifest].blank? ? :bad_request : :ok)
    head :ok
  end

  def list
    teacher = (current_account.role == :teacher) ? current_account.loggable : nil
    @quizzes = teacher.nil? ? [] : Quiz.where(:teacher_id => teacher.id).where('atm_key IS NOT NULL').order(:klass).order('created_at DESC')
  end

  def preview
    @quiz = Quiz.where(:atm_key => params[:id]).first
    head :bad_request if @quiz.nil?
  end

end
