class ImplementerRequestsController < ApplicationController
  before_action :set_implementer_request, only: [:show, :edit, :update, :destroy]
  before_filter :verify_is_admin , only: [:destroy]

  # GET /implementer_requests
  # GET /implementer_requests.json
  def index
    if  current_user.admin?
      @implementer_requests = ImplementerRequest.all
    else
      @implementer_requests = current_user.Implementer_requests
    end
  end

  # GET /implementer_requests/1
  # GET /implementer_requests/1.json
  def show
    s = @implementer_request.School
    p = @implementer_request.Program
    d = @implementer_request.start_date
    # @coor_imp = ImplementerRequest.where(School: s, Program: p, start_date: d)
    # @e = User.joins(@coor_imp).where()
    
    @coor_imp = ImplementerRequest.includes(:User).where(School: s, Program: p, start_date: d,:employees => {employee_type: 'Coordinator' } ).all
    
    @coor_imp.each do |company|
     puts company.User.name
    end
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
      @implementer_request.destroy
      respond_to do |format|
        format.html { redirect_to implementer_requests_url, notice: 'Implementer request was successfully destroyed.' }
        format.json { head :no_content }
      end
    end
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

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_implementer_request
      @implementer_request = ImplementerRequest.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def implementer_request_params
      params.require(:implementer_request).permit(:classroom, :start_date, :duration, :status, :school_id, :user_id, :program_id)
    end
end
