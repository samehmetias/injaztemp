class CompaniesController < ApplicationController

  before_action :set_company, only: [:show, :edit, :update, :destroy, :companyrequest]
  before_filter :authenticate_user!
  before_filter :verify_is_admin , except: [:index,:show]

  
  # GET /companies
  # GET /companies.json
  def index
    if  current_user.admin?
      @companies = Company.all.order(:name).page(params[:page]).per(10)
    else
      @companies = current_user.Company
    end
  end

  # GET /companies/1
  # GET /companies/1.json
  def show
    @req = @company.implementer_requests
  end

  # GET /companies/new
  def new
    @company = Company.new
  end

  # GET /companies/1/edit
  def edit
  end

  # POST /companies
  # POST /companies.json
  def create
    @company = Company.new(company_params)

    respond_to do |format|
      if @company.save
        format.html { redirect_to @company, notice: 'Company was successfully created.' }
        format.json { render :show, status: :created, location: @company }
      else
        format.html { render :new }
        format.json { render json: @company.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /companies/1
  # PATCH/PUT /companies/1.json
  def update
    respond_to do |format|
      if @company.update(company_params)
        format.html { redirect_to @company, notice: 'Company was successfully updated.' }
        format.json { render :show, status: :ok, location: @company }
      else
        format.html { render :edit }
        format.json { render json: @company.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /companies/1
  # DELETE /companies/1.json
  def destroy
    @company.destroy
    respond_to do |format|
      format.html { redirect_to companies_url, notice: 'Company was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def companyrequest
    @employees = User.where(company_id: @company.id)
    @coordinator = User.where(employee_type: 'Coordinator')
  end

  def createrequests
    @emp = User.find(params[:user_ids])
    info = params[:implementer_request]
    @emp.each do |e|
      t = ImplementerRequest.new
      t.program_id = info[:program_id]
      t.start_date = DateTime.new info["start_date(1i)"].to_i, info["start_date(2i)"].to_i, info["start_date(3i)"].to_i, info["start_date(4i)"].to_i, info["start_date(5i)"].to_i 
      t.start_time = DateTime.new info["start_time(1i)"].to_i, info["start_time(2i)"].to_i, info["start_time(3i)"].to_i, info["start_time(4i)"].to_i, info["start_time(5i)"].to_i 
      t.end_time = DateTime.new info["end_time(1i)"].to_i, info["end_time(2i)"].to_i, info["end_time(3i)"].to_i, info["end_time(4i)"].to_i, info["end_time(5i)"].to_i 
      t.school_id = info[:school_id]
      puts '++++++++++++++USER++++++++++++++++'
      puts e.inspect
      t.user_id = e.id
      t.save
      notifyUser('Hey '+t.user.name+'! You recieved implementation details for the following school: '+t.school.name,t.user_id)
    end
    redirect_to companies_url    
  end

  def notifyUser(message,u_id)
      apn = ApnHelper::Apn.new
      id = u_id
      u = Phone.where(user_id: id).first
      if (!(u.nil?))
        token = u.token
        # puts '++++++++++NotifyUser+++++++++++++'
        #   puts token
        # puts '++++++++++NotifyUser+++++++++++++'
        apn.delay(:priority => 1).sendAlert(token, "INJAZ Egypt",message,"",true)
        # render :text => '1'
      end
    end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_company
      @company = Company.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def company_params
      params.require(:company).permit(:name)
    end

end
