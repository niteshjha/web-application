class CoursesController < ApplicationController
  before_filter :authenticate_account!
  respond_to :json 

  def profile
    @course = Course.find params[:id]
  end

  def show 
    @course = Course.find(params[:id]) 
    @syllabi = Syllabus.where(:course_id => @course.id)
    respond_with @course, @syllabi 
  end 

  def update 
    course = Course.find params[:id] 
    status = :ok
    
    status = course.nil? ? :bad_request : 
            (course.update_attributes(params[:course]) ? :ok : :bad_request)
    head status 
  end 

  def search 
    head :ok
  end 

  def create 
   board_name = params[:course].delete :board 
   unless board_name.empty? 
     board = Board.where(:name => board_name).first 
     board = board.nil? ? Board.new(:name => board_name) : board 
     board.save if board.new_record? # Have to save board first else @course.board_id = nil
     @course = board.courses.new params[:course]
   else  
     @course = Course.new params[:course] 
   end 
   @course.save ? respond_with(@course) : head(:bad_request) 
  end 

  def list
    criterion = params[:criterion]
    unless criterion.nil?
      klass = criterion[:klass]
      subject = criterion[:subject]
      board = criterion[:board]
    else
      klass = subject = board = nil
    end 
    @courses = Course.klass?(klass).subject?(subject).board?(board)
  end 

  def coverage
    @course = Course.find params[:id]
    @verticals = Vertical.where('id IS NOT NULL').order(:name) # basically, everyone
  end 

  def verticals
    course = Course.find params[:id]
    head :bad_request if course.nil?
    @verticals = course.verticals
  end

  def applicable_topics 
    vertical_ids = params[:checked].keys.map(&:to_i)
    @topics = Topic.where(:vertical_id => vertical_ids).order(:name)
  end 

  def get_relevant_questions
    @course = Course.find params[:id]
    head :bad_request if @course.nil? 

    skip_used = params[:skip_previously_used] == "true" ? true : false
    teacher = skip_used ? params[:teacher_id].to_i : nil

    topic_ids = params[:checked].keys.map(&:to_i)
    @questions = @course.relevant_questions topic_ids, teacher
    respond_with @questions, @course
  end

end
