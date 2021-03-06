class LessonsController < ApplicationController
  before_action :set_lesson, only: [:show, :edit, :update, :destroy]
  before_filter :authenticate_user!
  before_filter :verify_is_admin , only: [:destroy,:create,:edit,:update]

  # GET /lessons
  # GET /lessons.json
  def index
    if  current_user.admin?
      @lessons = Lesson.all
    else
      @lessons = current_user.lessons
    end
  end


  # GET /lessons/1
  # GET /lessons/1.json
  def show
  end

  # GET /lessons/new
  def new
    @lesson = Lesson.new
  end

  # GET /lessons/1/edit
  def edit
    if  !current_user.admin?
      redirect_to implementer_requests_path
    end
  end

  # POST /lessons
  # POST /lessons.json
  def create
    @lesson = Lesson.new(lesson_params)

    respond_to do |format|
      if @lesson.save
        format.html { redirect_to @lesson, notice: 'Lesson was successfully created.' }
        format.json { render :show, status: :created, location: @lesson }
      else
        format.html { render :new }
        format.json { render json: @lesson.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /lessons/1
  # PATCH/PUT /lessons/1.json
  def update
    respond_to do |format|
      if @lesson.update(lesson_params)
        notifyUser(@lesson.name+' at '+@lesson.implementer_request.school.name+' has been modified. Please check the new updates',@lesson.implementer_request.user_id)
        if(Delayed::Job.where(queue: @lesson.id.to_s).delete_all)
          remindUser("You have a session tomorrow!",@lesson.implementer_request.user_id,@lesson.date,@lesson.id)
        end
        format.html { redirect_to @lesson, notice: 'Lesson was successfully updated.' }
        format.json { render :show, status: :ok, location: @lesson }
      else
        format.html { render :edit }
        format.json { render json: @lesson.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /lessons/1
  # DELETE /lessons/1.json
  def destroy
    id = @lesson.id
    @lesson.destroy
    Delayed::Job.where(queue: id.to_s).delete_all
    respond_to do |format|
      format.html { redirect_to lessons_url, notice: 'Lesson was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def notifyUser(message,u_id)
    apn = ApnHelper::Apn.new
    id = u_id
    Phone.where(user_id: id).each do |u|
      if (!(u.nil?))
        token = u.token
        puts '++++++++++NotifyUser+++++++++++++'
          puts token
        puts '++++++++++NotifyUser+++++++++++++'
        apn.delay(:priority => 1).sendAlert(token, "INJAZ Egypt",message,"",true)
        # render :text => '1'
      end
    end
  end

  def remindUser(message,u_id,di,q)
    apn = ApnHelper::Apn.new
    id = u_id
    Phone.where(user_id: id).each do |u|
      if (!(u.nil?))
        token = u.token
        puts '++++++++++remindUser+++++++++++++'
          puts token
        puts '++++++++++remindUser+++++++++++++'
        # apn.delay(:priority => 1).sendAlert(token, "INJAZ Egypt",message,"",true)
        if(!(self.status=='NO'))
          apn.delay(:priority => 1, :run_at => di - 1.days  , :queue => q.to_s).sendAlert(token, "INJAZ Egypt",message,"",true)
        end
        # render :text => '1'
      end
    end
  end 

  def accept
    @imp = set_lesson
    @imp.accept
    redirect_to lessons_path
  end
  
    def refuse
    @imp = set_lesson
    @imp.refuse
    redirect_to lessons_path
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_lesson
      @lesson = Lesson.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def lesson_params
      params.require(:lesson).permit(:name, :date, :status, :implementer_request_id)
    end
end
