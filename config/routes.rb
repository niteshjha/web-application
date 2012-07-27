Webapp::Application.routes.draw do

  # post "question/insert_new"

  # The :path_prefix is important to disambiguate paths devise creates 
  # from ones that one would create if he/she wants to update their own 
  # Account model. For example, to edit the email field in our own model,
  # we need a controller & controller actions. Paths corresponding them 
  # would be quite similar - if not the same - as those created by devise below

  devise_for :accounts, :path_prefix => 'gutenberg' do 
    get '/login' => 'devise/sessions#new'
    get '/logout' => 'devise/sessions#destroy'
  end 

  match 'ping' => 'application#ping', :via => :get

  # Account 
  resource :account, :only => [:update]
  match 'update_password' => 'accounts#update_password', :via => :put

  # Admin 
  resource :admin, :controller => :admin 

  # Board 
  resource :board, :only => [:create, :update]
  # match 'get_course_details/:board_id' => 'boards#get_course_details', :via => :get
  match 'boards/summary' => "boards#summary", :via => :get

  # Course
  resource :course, :only => [:show, :create, :update]
  match 'courses/list' => 'courses#list', :via => :get
  match 'course/profile' => 'courses#profile', :via => :get
  match 'course/coverage' => 'courses#coverage', :via => :get
  match 'course/verticals' => 'courses#verticals', :via => :get
  match 'course/questions' => 'courses#questions', :via => :put
  match 'course/topics_in' => 'courses#topics_in', :via => :get

  # Examiner 
  resource :examiner, :except => [:new, :destroy]
  match 'examiner/pending_quizzes' => 'examiners#pending_quizzes', :via => :get
  match 'examiner/block_db_slots' => 'examiners#block_db_slots', :via => :get
  match 'examiner/update_workset' => 'examiners#update_workset', :via => :get
  match 'examiners/list' => 'examiners#list', :via => :get
  match 'examiner/suggestions_just_in' => 'examiners#suggestions_just_in', :via => :get
  match 'examiner/suggestions_wip' => 'examiners#suggestions_wip', :via => :get

  # Grade
  resource :grade, :only => [:update]
  match 'assignGrades' => 'grades#assign', :via => :put

  # School 
  resource :school, :only => [:show, :create, :update]
  match 'add_students' => 'schools#add_students', :via => :post
  match 'schools/list' => 'schools#list', :via => :get 
  # match 'school/unassigned-students' => 'schools#unassigned_students', :via => :get
  match 'school/sektions' => 'schools#sektions', :via => :get

  # Verticals 
  resource :vertical, :only => [:create]
  match 'vertical/topics_in_course' => 'verticals#topics_in_course', :via => :get
  match 'verticals/list' => 'verticals#list', :via => :get
  match 'vertical/topics' => 'verticals#topics', :via => :get

  # Videos 
  resource :video, :only => [:create]
  match 'howtos' => 'videos#howtos'
  match 'video/load' => 'videos#load'

  # Topic 
  resource :topic, :only => [:create, :update]
  match 'topics/list' => 'topics#list', :via => :get

  # Question
  resource :question, :only => [:create, :update], :controller => :question
  match 'questions/list' => 'question#list', :via => :get
  match 'question/preview' => 'question#preview', :via => :get

  # Quiz
  resource :quiz, :only => [:show]
  match 'quizzes/list' => 'quizzes#list', :via => :get
  match 'quiz/preview' => 'quizzes#preview', :via => :get
  match 'quiz/assign' => 'quizzes#assign_to', :via => :put
  match 'quiz/pending_pages' => 'quizzes#pending_pages', :via => :get
  match 'quiz/pending_scans' => 'quizzes#pending_scans', :via => :get
  match 'quiz/testpapers' => 'quizzes#testpapers', :via => :get

  # Student 
  resource :student, :only => [:create, :update, :show]
  match 'student/responses' => 'students#responses', :via => :get

  # Sektion 
  resource :sektion, :only => [:create, :update]
  match 'sektions/list' => 'sektions#list', :via => :get
  match 'sektions/update_student_list' => 'sektions#update_student_list', :via => :put
  match 'sektions/students' => 'sektions#students', :via => :get
  match 'sektion/proficiency' => 'sektions#proficiency', :via => :get

  # Syllabus
  resource :syllabus, :only => [:show, :update]
   
  # Teacher 
  resource :teacher, :only => [:create, :update, :show]
  match 'teachers/list' => 'teachers#list', :via => :get
  # match 'teachers/roster' => 'teachers#roster', :via => :get 
  # match 'teacher/update_roster' => 'teachers#update_roster', :via => :put
  match 'teacher/coverage' => 'teachers#coverage', :via => :get
  match 'teacher/load' => 'teachers#load', :via => :get
  match 'teacher/courses' => 'teachers#courses', :via => :get
  match 'teacher/build_quiz' => 'teachers#build_quiz', :via => :put
  match 'teacher/testpapers' => 'teachers#testpapers', :via => :get
  match 'teacher/topics_this_section' => 'teachers#topics_this_section', :via => :get
  match 'teacher/like_q' => 'teachers#like_question', :via => :get
  match 'teacher/unlike_q' => 'teachers#unlike_question', :via => :get
  match 'update_specialization' => 'teachers#update_specialization', :via => :post

  # Testpaper
  match 'testpaper/summary' => 'testpapers#summary', :via => :get

  # Trial Account 
  resource :trial_account, :only => [:create], :controller => :trial_account
  
  # Welcome
  match 'about_us' => 'welcome#about_us', :via => :get
  match 'try_us' => 'welcome#try_us', :via => :get
  match 'download' => 'welcome#download', :via => :get
  match 'how_it_works' => 'welcome#how_it_works', :via => :get

  # Yardstick
  resource :yardstick, :only => [:show, :create, :update]
  match 'yardsticks/preview' => 'yardsticks#preview', :via => :get

  # Suggestion 
  match 'suggestion/block_db_slots' => 'suggestions#block_db_slots', :via => :post
  
  root :to => "welcome#index"

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => "welcome#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
