class TestpapersController < ApplicationController
  before_filter :authenticate_account!
  respond_to :json

  def summary
    # students who got this testpaper
    @testpaper = Testpaper.find params[:id]
    head :bad_request if @testpaper.nil?
    @mean = @testpaper.mean?
    @students = @testpaper.students.order(:first_name)
    @answer_sheet = AnswerSheet.where(:testpaper_id => @testpaper.id)
    @max = @testpaper.quiz.total?
  end

  def load 
    @testpaper = Testpaper.find params[:id]
  end

  def preview # the answer-key actually
    ws = Testpaper.find params[:id].to_i
    @quiz = ws.nil? ? nil : Quiz.where(:id => ws.quiz_id).first
  end 

  def layout
    # Returns ordered list of questions - renderable as .tabs-left
    ws = Testpaper.find params[:id]
    @who = current_account.loggable_type
    unless ws.nil?
      @quiz = ws.quiz
      @subparts = Subpart.in_quiz(@quiz.id)
    else
      head :bad_request 
    end
  end

end
