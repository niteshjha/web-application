class ExaminersController < ApplicationController
  before_filter :authenticate_account!, :except => [:update_workset]
  respond_to :json

  def create 
    added = true
    params[:examiners].each_value do |v,index|
      name = v[:name]
      as_admin = v[:admin].blank? ? false : true

      next if name.blank?
      #puts "#{name} --> #{as_admin}"

      examiner = Examiner.new :name => name, :is_admin => as_admin
      username = create_username_for examiner, (as_admin ? :admin : :examiner)
      email = "#{username}@drona.com" # default. Can be changed later by the examiner
      account = examiner.build_account :email => email, :username => username, 
                                       :password => "123456", :password_confirmation => "123456"
      added &= examiner.save
      break if !added 
    end
    added ? head(:ok) : head(:bad_request)
  end 

  def show
    render :nothing => true, :layout => 'examiner'
  end

  def list 
    @examiners = Examiner.order(:last_name)
  end 

  def pending_quizzes
    examiner = Examiner.where(:id => current_account.loggable_id).first
    head :bad_request if examiner.nil?
    @quizzes = examiner.pending_quizzes 
  end

  def block_db_slots
    examiner = Examiner.find params[:id]
    slots = examiner.block_db_slots
    render :json => {:slots => slots}, :status => :ok
  end

  def update_workset
    failures = Examiner.receive_scans
    render :json => failures, :status => :ok
  end

  def suggestions
    examiner = params[:id].blank? ? current_account.loggable : Examiner.find(params[:id])
    unless examiner.nil?
      @all = examiner.suggestions 
      @wips = @all.wip
      @just_in = @all.just_in
      @completed = @all.completed
    else
      @all = @wips = @just_in = @completed = []
    end
  end # of method

end
