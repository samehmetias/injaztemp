class ImplementerRequestsController < ApplicationController
  before_action :set_implementer_request, only: [:show, :edit, :update, :destroy]
  before_filter :authenticate_user!
  before_filter :verify_is_admin , only: [:destroy]

  # GET /implementer_requests
  # GET /implementer_requests.json
  def index
    if  current_user.admin?
      @implementer_requests = ImplementerRequest.all
    else
      @implementer_requests = current_user.implementer_requests
    end
  end

  # GET /implementer_requests/1
  # GET /implementer_requests/1.json
  def show
    s = @implementer_request.school
    p = @implementer_request.program
    d = @implementer_request.start_date

    #@coor_imp = ImplementerRequest.where(school_id = s.id)
    # @e = User.joins(@coor_imp).where()
    
   @coor_imp = ImplementerRequest.includes(:user).where(school: s, program: p, start_date: d,:users => {employee_type: 'Coordinator' } ).all
   @sessions = @implementer_request.lessons
  end

  # GET /implementer_requests/new
  def new
     @implementer_request = ImplementerRequest.new
  end

  # GET /implementer_requests/1/edit
  def edit
    if  !current_user.admin?
      redirect_to implementer_requests_path
    end
  end

  # POST /implementer_requests
  # POST /implementer_requests.json
  def create
    @implementer_request = ImplementerRequest.new(implementer_request_params)


    respond_to do |format|
      if @implementer_request.save
        notifyUser('Hey '+@implementer_request.user.name+'! You recieved implementation details for the following school: '+@implementer_request.school.name,@implementer_request.user_id)
        format.html { redirect_to @implementer_request, notice: 'Implementer request was successfully created.' }
        format.json { render :show, status: :created, location: @implementer_request }

      else
        format.html { render :new }
        format.json { render json: @implementer_request.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /implementer_requests/1
  # PATCH/PUT /implementer_requests/1.json
  def update
    respond_to do |format|
      if @implementer_request.update(implementer_request_params)
        notifyUser('Your implementation details have been updated',@implementer_request.user_id)
        format.html { redirect_to @implementer_request, notice: 'Implementer request was successfully updated.' }
        format.json { render :show, status: :ok, location: @implementer_request }
      else
        format.html { render :edit }
        format.json { render json: @implementer_request.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /implementer_requests/1
  # DELETE /implementer_requests/1.json
  def destroy
    if  !current_user.admin?
      redirect_to implementer_requests_path
    else
      @implementer_request.lessons.each do |l|
        Delayed::Job.where(queue: l.id.to_s).delete_all
      end
      @implementer_request.destroy
      respond_to do |format|
        format.html { redirect_to implementer_requests_url, notice: 'Implementer request was successfully destroyed.' }
        format.json { head :no_content }
      end
    end
  end

  def postpone
    set_implementer_request.postpone Integer(params[:num])
    redirect_to :back
  end
  
  def accept
    @imp = set_implementer_request
    @imp.accept
    redirect_to implementer_requests_path
  end
  
  def refuse
    @imp = set_implementer_request
    @imp.refuse
    redirect_to implementer_requests_path
  end

  def notifyUser(message,u_id)
    apn = ApnHelper::Apn.new
    id = u_id
    u = Phone.where(user_id: id).first
    if (!(u.nil?))
      token = u.token
      puts '++++++++++NotifyUser+++++++++++++'
        puts token
      puts '++++++++++NotifyUser+++++++++++++'
      apn.delay(:priority => 1).sendAlert(token, "INJAZ Egypt",message,"",true)
      # render :text => '1'
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_implementer_request
      @implementer_request = ImplementerRequest.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def implementer_request_params
      params.require(:implementer_request).permit(:classroom, :start_date, :duration, :status, :school_id, :user_id, :program_id,:start_time,:end_time)
    end
end
