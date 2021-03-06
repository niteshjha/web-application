class TeachersController < ApplicationController
  before_filter :authenticate_account!, :except => [:create]
  respond_to :json

  def create
    data = params[:teacher]

    if data[:guard].blank? # => human entered registration data
      country = data[:country].blank? ? nil : Country.where{ name =~ "%#{data[:country]}%" }.first

      teacher = Teacher.new :name => data[:name]

      location = request.location
      city = state = country = zip = nil

      unless location.nil?
         city = location.city
         state = location.state
         zip = location.postal_code
         country = location.country
         # Mailbot.registration_debug(city, state, zip, country).deliver
         country = Country.where{ name =~ country }.first
         country = country.id unless country.blank?
      end

      account_details = data[:account]
      account = teacher.build_account :email => account_details[:email], 
                                      :password => account_details[:password],
                                      :password_confirmation => account_details[:password],
                                      :city => city,
                                      :state => state, 
                                      :postal_code => zip,
                                      :country => country
                                     
      if teacher.save 
        Mailbot.welcome_teacher(teacher.account).deliver
        sign_in teacher.account
        redirect_to teacher_path
      end # no reason for else if client side validations worked
    else # registration data probably entered by a bot
      render :json => { :notify => { :text => "Bot?" } }, :status => :bad_request
    end
  end 

  def show 
    render :nothing => true, :layout => 'teachers'
  end 

  def load
    @teacher = Teacher.find params[:id]
  end

  def worksheets
    teacher = current_account.loggable 
    head :bad_request if teacher.nil?
    @worksheets = teacher.worksheets
  end

  def update 
    teacher = Teacher.find params[:id]
    head :bad_request if teacher.nil?
    status = teacher.update_attributes(params[:teacher]) ? :ok : :bad_request
    head status 
  end 


  def list 
    if current_account
      @who_wants_to_know = current_account.role
      case @who_wants_to_know
        when :admin
          @teachers = Teacher.where(:school_id => params[:id])
        when :school 
          @teachers = Teacher.where(:school_id => current_account.loggable.id)
        when :student 
          @teachers = current_account.loggable.teachers 
        else 
          @teachers = [] 
      end 
      respond_with @teachers, @who_wants_to_know
    else
      head :bad_request 
    end 
  end 

  def sektions
    teacher = params[:id].nil? ? current_account.loggable : Teacher.find(params[:id])
    if teacher.nil?
      @sektions = []
    else
      @sektions = teacher.sektions
      @sektions = Sektion.where(:id => PREFAB_SECTION) if @sektions.blank?
    end
    @context = params[:context]
  end

  def students 
    teacher = Teacher.find params[:id]
    all = (params[:exclusive] == "yes") ? false : true 
    @students = teacher.nil? ? [] : teacher.students(all).order(:first_name)
  end 

  def students_with_names
    teacher = Teacher.find params[:id]
    all = (params[:exclusive] == "yes") ? false : true 
    starting_with = [*"#{params[:start]}".."#{params[:end]}"]
    @students = teacher.nil? ? [] : teacher.students(all, starting_with)
  end

  def suggested_questions
    teacher = current_account.loggable_type == "Teacher" ? current_account.loggable : nil
    unless teacher.nil? 
      @questions = teacher.suggested_questions :completed
    else
      @questions = []
    end
  end

  def qzb_echo
    tids = params[:checked].keys.map(&:to_i)
    @topics = Topic.where(:id => tids)
    @filters = params[:filter].blank? ? [] : params[:filter].keys
    @context = params[:context]
  end

  def build_quiz 
    teacher_id = current_account.loggable_type == "Teacher" ? current_account.loggable_id : nil
    head :bad_request if teacher_id.nil? 

    name = params[:checked].delete :name
    question_ids = params[:checked].keys.map(&:to_i)
    quiz = Quiz.new :name => name, :teacher_id => teacher_id, 
                    :question_ids => question_ids, 
                    :num_questions => question_ids.count

    status = quiz.save ? :ok : :bad_request
    unless status == :bad_request
      job = Delayed::Job.enqueue CompileQuiz.new(quiz)
      quiz.update_attribute :job_id, job.id

      estimate = minutes_to_completion job.id
      render :json => { :monitor => { :quiz => quiz.id }, 
                        :notify => { :title => "#{estimate} minute(s)" }},
                        :status => :ok
    else
      render :json => { :monitor => { :quiz => nil } }, :status => :ok
    end
  end

  def disputed 
    teacher = Teacher.find params[:id]
    head :bad_request if teacher.nil?

    @disputed = GradedResponse.in_quiz(teacher.quiz_ids).disputed
    quiz_ids = QSelection.where(:id => @disputed.map(&:q_selection_id)).map(&:quiz_id).uniq
    @quizzes = Quiz.where(:id => quiz_ids)
  end

  def overwrite_marks
    params[:disputed].each do |id, marks|
      g = GradedResponse.where(:id => id).first
      marks = marks.empty? ? nil : marks.to_f.round(2)
      next if marks.nil? || marks < 0 || marks > g.subpart.marks
      g.update_attributes :marks_teacher => marks, :closed => true
    end
    render :json => { :status => :done }, :status => :ok
  end

  def prefabricate
    topic = params[:prefab][:topic]
    quiz = Quiz.find topic.to_i 

    clone = quiz.clone current_account.loggable_id
    unless clone.nil?
      job = Delayed::Job.enqueue CompileQuiz.new(clone)
      clone.update_attribute :job_id, job.id

      # Now, randomly pick a student from the prefabricated section - Gradians.com 
      sk = Sektion.find PREFAB_SECTION
      random_student = sk.students.order(:created_at)[ [*2..10].sample ] # first 2 students are the founders

      # and assign the just made quiz to him / her 
      ws = clone.assign_to [random_student]
      unless ws.nil?
        job = Delayed::Job.enqueue CompileTestpaper.new(ws, false)
        ws.update_attribute :job_id, job.id
        estimate = minutes_to_completion job.id
        render :json => { :monitor => { :quiz => clone.id, :worksheet => ws.id }, 
                          :timer => { :on => topic, :for => "#{estimate * 60}"} },
                          :status => :ok
      end
    else # no clone. should never happen
      render :nothing => true, :status => :ok
    end
  end

  def add_lesson
    teacher = current_account.loggable
    data = params[:lesson]

    lesson = teacher.lessons.build(name: data[:name], description: data[:description], history: (data[:type] == "h") )
    lesson.build_video(sublime_title: data[:name], sublime_uid: data[:uid], active: true)

    if lesson.save
      render json: { status: 'success' }, status: :ok
    else
      render json: { status: 'failed' }, status: :ok
    end
  end

end # of class
