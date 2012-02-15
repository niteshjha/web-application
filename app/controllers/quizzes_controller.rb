class QuizzesController < ApplicationController
  before_filter :authenticate_account!
  respond_to :json, :xml

  def create
    # teachers/behaviour.js.coffee is where this POST request was structured
    teacher = Teacher.find params[:id]
    selected = params[:selected]

    selected.each_with_index do |q, index|
      selected[index] = q.to_i
    end

    subject = Subject.where(:name => params[:subject]).select(:id).first.id
    @quiz = Quiz.new :teacher_id => teacher.id, :question_ids => selected, 
                     :num_questions => selected.count, :subject_id => subject, 
                     :klass => params[:klass]

    status = @quiz.save ? :ok : :bad_request
    unless status == :bad_request
      response = @quiz.compile_tex
      if response[:manifest].blank? 
        status = :bad_request
        @quiz.destroy
      else 
        # The atm-key is the randomized access point to this quiz in mint/
        atm_key = Quiz.extract_atm_key response[:manifest][:root]
        @quiz.update_attribute :atm_key, atm_key

        response = {:atm_key => atm_key, :name => @quiz.name }
        status = :ok
      end
      render :json => response, :status => status 
    else
      head :bad_request
    end 
  end 

  def assign_to
    quiz = Quiz.where(:atm_key => params[:id]).first 
    head :bad_request if quiz.nil?
    teacher = quiz.teacher 

    students = Student.where(:id => params[:checked].keys)
    response = quiz.assign_to students
    render :json => response, :status => (response[:manifest].blank? ? :bad_request : :ok)
  end

  def list
    teacher = (current_account.role == :teacher) ? current_account.loggable : nil
    @quizzes = teacher.nil? ? [] : Quiz.where(:teacher_id => teacher.id).where('atm_key IS NOT NULL').order(:klass)
  end

  def preview
    @quiz = Quiz.where(:atm_key => params[:id]).first
    head :bad_request if @quiz.nil?
  end

end
