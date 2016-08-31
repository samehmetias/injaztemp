module Api
    module V1
        class IosController < BaseController
            before_action :get_user
            skip_before_filter :restrict_access ,:only => [:configurations, :android_update, :login, :create_device, :age_groups, :sign_up, :forgot_password]

            # Create the APN Device
            def create_device
                puts "=============================="
                puts "Device"
                puts "=============================="
                phone = Phone.where('uuid=?', params[:device_uuid]).first
                if phone
                    phone.token = params[:regId]
                    phone.save
                else
                    if params[:is_android] == "true"
                        p = Phone.create(:is_android => true, :uuid => params[:device_uuid] , :token => params[:regId])
                    else
                        p = Phone.create(:is_android => false, :uuid => params[:device_uuid] , :token => params[:regId])
                    end
                end
                render :status=>200, :json=>{:success=>"1", :message=>"Success", :url => "create_device"}
            end

            def get_user
                puts "=============================="
                puts "Getting User!!"
                puts "=============================="
                token = request.headers["HTTP_AUTHORIZATION"].gsub(/Token realm=/,'').gsub(/Token token=/,'').gsub('"','') if request.headers["HTTP_AUTHORIZATION"]
                if request.headers["HTTP_AUTHORIZATION"] and token
                    api_key = ApiKey.find_by_key(token)
                    @@current_user = api_key.user if api_key != nil
                else
                    @@current_user = ""
                end
                puts "============TOKEN=================="
                puts token.inspect
                puts "=============================="
                puts "=============================="
                puts @@current_user
                puts "=============================="
            end

            def android_update
                render :status=>200, :json=>{:success=>"1", :message=>"Success", :url=>"android_update", :version_code=>"1", :must_update=>"false"}
            end

            def login
                if request.format != :json 
                    render :status=>406, :json=>{:success=>"0", :message=>"The request must be json" }
                    return
                end
                if params[:email].nil? or params[:password].nil?
                    render :status=>406,
                    :json=>{:success=>"0", :message => "Invalid Request Data" }
                    return
                end

                #authenticate User
                @@current_user = User.find_by_email(params[:email].downcase)
                if @@current_user.nil?
                    return render :status=>200, :json=>{:success=>"0", :message=>"Invalid username or password"}
                end
                if !@@current_user.valid_password?(params[:password])
                    return render :status=>200, :json=>{:success=>"0", :message=>"Invalid username or password"}
                end

                @@current_user.ensure_authentication_token!
                userToken = @@current_user.api_key.key.to_s

                requestsArray = []
                requests = ImplementerRequest.where(user_id: @@current_user.id)
                requests.each do |r|
                    e = {}
                    e['request_id'] = r.id.to_s
                    e['request_school_name'] = r.school.name
                    e['request_school_location'] = r.school.district
                    e['request_program'] = r.program.name
                    e['request_start_date'] = r.start_date.strftime('%d.%m.%y at %I:%M %p')
                    e['request_duration'] = r.program.duration.to_s
                    e['request_classroom'] = r.classroom.to_s
                    e['request_status'] = r.status
                    coords_requests = r.getCoordinators
                    i = 0
                    while i < coords_requests.count do
                      e['request_coord_name'+i.to_s] = coords_requests[i].user.name
                      e['request_coord_telephone'+i.to_s] = coords_requests[i].user.telephone.to_s
                      i = i+1
                    end
                    requestsArray.push(e)
                end

                lessonsArray = []
                lessons = @@current_user.lessons
                lessons.each do |r|
                    e = {}
                    e['lesson_id'] = r.id.to_s
                    e['lesson_name'] = r.name
                    e['lesson_school_name'] = r.implementer_request.school.name
                    e['lesson_program_name'] = r.implementer_request.program.name
                    e['lesson_date'] = r.date.strftime('%d.%m.%y at %I:%M %p')
                    e['lesson_classroom'] = r.implementer_request.classroom.to_s
                    e['lesson_status'] = r.status

                    lessonsArray.push(e)
                end

                programsArray = []
                programs = @@current_user.programs
                programs.each do |r|
                    e = {}
                    e['program_id'] = r.id.to_s
                    e['program_name'] = r.name
                    e['program_duration'] = r.duration.to_s
                    e['program_participants'] = r.participants
                    e['program_overview'] = r.overview

                    programsArray.push(e)
                end

                render :status=>200, :json=>{:success=>"1", :message=>"Success", :url=>"login", :user=>{id: @@current_user.id.to_s, name: @@current_user.name, company_name: @@current_user.company.name, telephone: @@current_user.telephone.to_s}, :token=>userToken, :requests => requestsArray, :lessons => lessonsArray, :programs => programsArray}

            end

            def get_all_requests
                requestsArray = []
                requests = ImplementerRequest.where(user_id: @@current_user.id)
                #requests = ImplementerRequest.all.order("start_date ASC")
                requests.each do |r|
                    e = {}
                    e['request_id'] = r.id.to_s
                    e['request_school_name'] = r.school.name
                    e['request_school_location'] = r.school.district
                    e['request_program'] = r.program.name
                    e['request_start_date'] = r.start_date.strftime('%d.%m.%y at %I:%M %p')
                    e['request_duration'] = r.program.duration.to_s
                    e['request_classroom'] = r.classroom.to_s
                    e['request_status'] = r.status
                    coords_requests = r.getCoordinators
                    i = 0
                    if (!(coords_requests.nil?))
                      while i < coords_requests.count do
                        e['request_coord_name'+i.to_s] = coords_requests[i].user.name
                        e['request_coord_telephone'+i.to_s] = coords_requests[i].user.telephone.to_s
                        i = i+1
                     end  
                    end
                    
                    requestsArray.push(e)
                end
                render :status=>200, :json=>{:success=>"1", :message=>"Success", :url=>"get_all_requests", :requests => requestsArray}
                
            end
            def get_one_request
                request = ImplementerRequest.where(id: params[:rid]).first
                if request.nil?
                    return render :status=>200, :json=>{:success=>"0", :message=>"No request found"}
                end
                coords_requests = request.getCoordinators
                if(coords_requests.nil?)
                    c=0
                else
                    c=coords_requests.count
                end
                if(c > 0)
                    render :status=>200, :json=>{:success=>"1", :message=>"Success", :url=>"get_one_request",request_id:request.id.to_s,request_school_name: request.school.name,request_school_location: request.school.district,
                        request_school_address: request.school.address, request_lat: request.school.latitude,request_long: request.school.longitude,request_program: request.program.name,request_start_date: request.start_date.strftime('%d.%m.%y at %I:%M %p'),request_duration: request.program.duration.to_s,request_classroom: request.classroom.to_s,request_status: request.status, request_coor_num: coords_requests.count.to_s, request_coord_name: coords_requests[0].user.name,request_coord_telephone: coords_requests[0].user.telephone.to_s}
                else
                    render :status=>200, :json=>{:success=>"1", :message=>"Success", :url=>"get_one_request", :request_id => request.id.to_s,:request_school_name => request.school.name,:request_school_location => request.school.district,request_school_address: request.school.address, request_lat: request.school.latitude,request_long: request.school.longitude,:request_program => request.program.name,:request_start_date => request.start_date.strftime('%d.%m.%y at %I:%M %p'),:request_duration => request.program.duration.to_s,:request_classroom => request.classroom.to_s,:request_status => request.status, request_coor_num: "0"}
                end
            end

            def get_all_programs
                programsArray = []
                programs = Program.where(user_id: @@current_user.id)
                # programs = Program.all
                programs.each do |r|
                    e = {}
                    e['program_id'] = r.id.to_s
                    e['program_name'] = r.name
                    e['program_duration'] = r.duration.to_s
                    e['program_participants'] = r.participants
                    e['program_overview'] = r.overview

                    programsArray.push(e)
                end
                render :status=>200, :json=>{:success=>"1", :message=>"Success", :url=>"get_all_programs", :programs => programsArray}
            end

            def get_one_program
                program = Program.where(id: params[:pid]).first
                if program.nil?
                    return render :status=>200, :json=>{:success=>"0", :message=>"No program found"}
                end
                    render :status=>200, :json=>{:success=>"1", :message=>"Success", :url=>"get_one_request", :program_id => program.id.to_s,:program_name => program.name,:program_duration => program.duration.to_s,:program_overview => program.overview}
            end

            def get_all_sessions
                lessonsArray = []
                lessons = @@current_user.lessons.order("date ASC")
                lessons.each do |r|
                    e = {}
                    e['lesson_id'] = r.id.to_s
                    e['lesson_name'] = r.name
                    e['lesson_school_name'] = r.implementer_request.school.name
                    e['lesson_program_name'] = r.implementer_request.program.name
                    e['lesson_date'] = r.date.strftime('%d.%m.%y at %I:%M %p')
                    e['lesson_classroom'] = r.implementer_request.classroom.to_s
                    e['lesson_status'] = r.status

                    lessonsArray.push(e)
                end
                render :status=>200, :json=>{:success=>"1", :message=>"Success", :url=>"get_all_sessions", :lessons => lessonsArray}
                
            end

            def respond_to_request
                response = params[:response]
                request = ImplementerRequest.where(id: params[:rid]).first
                if(response == '0')
                    request.refuse
                else
                    request.accept
                end
                render :status=>200, :json=>{:success=>"1", :message=>"Success", :url=>"respond_to_request"}
            end

            def respond_to_session
                response = params[:response]
                lesson = Lesson.where(id: params[:sid]).first

                if(response == '0')
                    lesson.refuse
                else
                    lesson.accept
                end
                render :status=>200, :json=>{:success=>"1", :message=>"Success", :url=>"respond_to_request"}
            end

            def about_injaz
               render :status=>200, :json=>{:success=>"1", :message=>"Success", :url=>"about_injaz", :info => "INJAZ Egypt delivers experiential learning in financial literacy, work readiness and entrepreneurship, effectively enriching the ability of young people (between the ages of 11 and 27) to both engage in their own economic development and contribute to the strength of their communities and economies. INJAZ has been working in Egypt for more than a decade under the Ministry of Social Solidarity, as an Egyptian NGO, and in collaboration with the Ministry of Education. INJAZ Egypt is a member nation of Junior Achievement Worldwide (JAW), the world’s largest and fastest growing organization specializing in economic education. It is also part of the regional network INJAZ Al-Arab, which harnesses the mentorship of Arab business leaders to help inspire a culture of entrepreneurialism and business innovation among Arab youth."} 
            end

            def tips_and_tricks
                classroom_tips_titles= ['Avoid controversial subjects i.e. religion, politics, sports etc.','Call the students by their names','Make the classroom space interactive & friendly','Avoid talking for longer than 10 minutes at a time','Show excitement at being in class']
                
                classroom_tips_contents = ['Students can be very sensitive towards controversial subjects, and they can instigate unnecessary arguments, thus dividing the students and inhibiting cooperation. Avoid discussing such matters, including football club teams (i.e. Ahly vs. Zamalek).','Using the students’ names rather than just anonymously calling them helps them feel recognized, communicates respect, and boosts the shy or withdrawn students’ confidence.','Arranging the classroom in a U-shape or circles, for example, allows the  lunteer to move around the classroom more, increasing the amount of interaction as well as the volunteer’s awareness of each student.','The average attention span of most adolescents is 10 – 12 minutes, sospeaking longer than that will most likely leave students unfocused and inattentive of what is being said.','According to UCLA psychology Professor Albert Mehrabian, 93% of communication is non-verbal, comprising of 55% body language and 38% tone of voice, so in order for the students to cooperate and be excited about the program, they must be able to perceive your interest and excitement.']

                dos = ['Establish an effective contract during the very first session by:','Make a first impression that will equally solicit enthusiasm towards the program and respect towards you.','Be on time to class as that portrays a professional image to the students and facilitates delivering the program content in its entirety.','If the teacher is present in class, encourage them to:','It is important not to let the teacher’s presence distract you from focusing your attention on the students. If the teacher asks about the program, consult with the coordinator in order to give him/her a copy of the guidebook.']

                donts = ['Dismiss students from class, as that goes against INJAZ’s educational philosophy.','Ask the teacher to help you manage the students/classroom or assign them the task of giving instructions to the students.','Talk about anything controversial as this can instigate unnecessary arguments, thus dividing the students and inhibiting cooperation. Avoid discussing matters such as religion, politics, football club teams (i.e. Ahly vs. Zamalek).']

                contract = ['Explaining how this contract is similar to contracts that are signed at work places when someone is new to a job; it is important to tie in the market place from the very first session!','Listening to the students’ suggestions; make sure to involve them so that they feel ownership towards it and are more likely to uphold it','Clarifying vague concepts (ex. instead of “respect,” encourage specificity such as agreeing not to interrupt peers or the volunteer)','Including the hand gesture of staying quiet to signify its importance','Clarifying what the consequences of breaking the agreed upon contract terms will be','Creating a space for 2 signatures: 1 for the volunteer and 1 for the student','Remembering to hang the contract during every session','Using the term “contract” not “rules and regulations” when referring to the agreed upon terms.','Using the term “result” or “consequence” not “punishment” when referring to a term in the contract that a student breaks.']

                teacher = ['Be in charge of keeping track of time during an activity','Help the volunteer distribute surveys, name tags, etc.','Keep track of team scores']



                render :status=>200, :json=>{:success=>"1", :message=>"Success", :url=>"tips_and_tricks", :tips_titles=>classroom_tips_titles, :tips_contents => classroom_tips_contents, :dos => dos, :donts => donts, :contract => contract, :teacher => teacher}

            end


            def age_groups
                ageGroupsArray = []
                ageGroups = AgeGroup.where(deleted: false)
                ageGroups.each do |group|
                    g = {}
                    g['group_id'] = group.id.to_s
                    g['group_name'] = group.name
                    ageGroupsArray.push(g)
                end
                render :status=>200, :json=>{:success=>"1", :message=>"Success", :url=>"age_groups", :age_groups=>ageGroupsArray}
            end

            def sign_up
                u = User.find_by_email(params[:email].downcase)
                return render :status=>200, :json=>{:success=>"0", :message=>"This email is already in use"} if u

                u = User.new
                name = params[:name].downcase.split.map(&:capitalize)*' '
                u.name = params[:name].downcase.split.map(&:capitalize)*' '
                u.email = params[:email]
                u.password = params[:password]
                u.mobile_no = params[:mobile]
                u.date_of_birth = params[:date_of_birth]
                u.gender = params[:gender]
                u.age_group_id = params[:age_group].to_i
                image = Paperclip.io_adapters.for(params[:profile_picture])
                image.original_filename = (name.sub! ' ', '_') + ".gif"
                u.profile_picture = image
                u.save

                @@current_user = User.find_by_email(params[:email])
                if @@current_user.nil?
                    return render :status=>200, :json=>{:success=>"0", :message=>"Sign up failed"}
                end
                @@current_user.valid_password?(params[:password])
                @@current_user.ensure_authentication_token!
                userToken = @@current_user.api_key.key.to_s
                render :status=>200, :json=>{:success=>"1", :message=>"Success", :url=>"sign_up", :user=>{id: @@current_user.id.to_s, name: @@current_user.name}, :token=>userToken}
            end

            def get_past_events
                pastEventsArray = []
                pastEvents = Event.where('date<?', Date.today).order("date DESC").limit(10)
                pastEvents.each do |event|
                    e = {}
                    e['event_id'] = event.id.to_s
                    e['event_name'] = event.name
                    e['event_location'] = event.location.name
                    e['event_location_address'] = event.location.address
                    e['event_location_position'] = event.location.latitude + "," + event.location.longitude + "(" + event.location.name + ")"
                    e['event_location_image_medium'] = event.location.image.url(:medium)
                    e['event_location_image_thumb'] = event.location.image.url(:thumb)
                    e['event_meeting_point'] = event.meeting_point.name
                    e['date'] = event.date.strftime('%d.%m.%y')
                    e['start_time'] = event.start_time.strftime('%I:%M %p')
                    e['end_time'] = event.end_time.strftime('%I:%M %p')
                    e['meeting_time'] = event.meeting_time.strftime('%I:%M %p')
                    e['description'] = event.description
                    rsvp = UserEvent.where("user_id=? and event_id=?", @@current_user.id, event.id).first
                    if rsvp
                        e['rsvp'] = rsvp.rsvp
                    else
                        e['rsvp'] = -1
                    end
                    pastEventsArray.push(e)
                end
                render :status=>200, :json=>{:success=>"1", :message=>"Success", :url=>"get_past_events", :past_events=>pastEventsArray}
            end

            def get_more_past_events
                pastEventsArray = []
                pastEvents = Event.where('date<? and id<?', Date.today, params[:id]).order("date DESC").limit(10)
                pastEvents.each do |event|
                    e = {}
                    e['event_id'] = event.id.to_s
                    e['event_name'] = event.name
                    e['event_location'] = event.location.name
                    e['event_location_address'] = event.location.address
                    e['event_location_position'] = event.location.latitude + "," + event.location.longitude + "(" + event.location.name + ")"
                    e['event_location_image_medium'] = event.location.image.url(:medium)
                    e['event_location_image_thumb'] = event.location.image.url(:thumb)
                    e['event_meeting_point'] = event.meeting_point.name
                    e['date'] = event.date.strftime('%d.%m.%y')
                    e['start_time'] = event.start_time.strftime('%I:%M %p')
                    e['end_time'] = event.end_time.strftime('%I:%M %p')
                    e['meeting_time'] = event.meeting_time.strftime('%I:%M %p')
                    e['description'] = event.description
                    rsvp = UserEvent.where("user_id=? and event_id=?", @@current_user.id, event.id).first
                    if rsvp
                        e['rsvp'] = rsvp.rsvp
                    else
                        e['rsvp'] = -1
                    end
                    pastEventsArray.push(e)
                end
                render :status=>200, :json=>{:success=>"1", :message=>"Success", :url=>"get_more_past_events", :past_events=>pastEventsArray}
            end

            def get_upcoming_events
                upcomingEventsArray = []
                upcomingEvents = Event.where('date>=?', Date.today).order("date ASC").limit(10)
                upcomingEvents.each do |event|
                    e = {}
                    e['event_id'] = event.id.to_s
                    e['event_name'] = event.name
                    e['event_location'] = event.location.name
                    e['event_location_address'] = event.location.address
                    e['event_location_position'] = event.location.latitude + "," + event.location.longitude
                    e['event_location_image_medium'] = event.location.image.url(:medium)
                    e['event_location_image_thumb'] = event.location.image.url(:thumb)
                    e['event_meeting_point'] = event.meeting_point.name
                    e['date'] = event.date.strftime('%d.%m.%y')
                    e['due'] = (event.date - Date.today).to_i
                    e['start_time'] = event.start_time.strftime('%I:%M %p')
                    e['end_time'] = event.end_time.strftime('%I:%M %p')
                    e['meeting_time'] = event.meeting_time.strftime('%I:%M %p')
                    e['description'] = event.description
                    rsvp = UserEvent.where("user_id=? and event_id=?", @@current_user.id, event.id).first
                    if rsvp
                        e['rsvp'] = rsvp.rsvp
                    else
                        e['rsvp'] = -1
                    end
                    upcomingEventsArray.push(e)
                end
                no_of_events = UserEvent.joins(:event).where("events.date>=? and user_events.rsvp=? and user_events.user_id=?", Date.today, 0, @@current_user.id).count
                render :status=>200, :json=>{:success=>"1", :message=>"Success", :url=>"get_upcoming_events", :upcoming_events=>upcomingEventsArray, :no_of_events=>no_of_events}
            end

            def get_more_upcoming_events
                upcomingEventsArray = []
                upcomingEvents = Event.where('date>=? and id<?', Date.today, params[:id]).order("date ASC").limit(10)
                upcomingEvents.each do |event|
                    e = {}
                    e['event_id'] = event.id.to_s
                    e['event_name'] = event.name
                    e['event_location'] = event.location.name
                    e['event_location_address'] = event.location.address
                    e['event_location_position'] = event.location.latitude + "," + event.location.longitude
                    e['event_location_image_medium'] = event.location.image.url(:medium)
                    e['event_location_image_thumb'] = event.location.image.url(:thumb)
                    e['event_meeting_point'] = event.meeting_point.name
                    e['date'] = event.date.strftime('%d.%m.%y')
                    e['due'] = (event.date - Date.today).to_i
                    e['start_time'] = event.start_time.strftime('%I:%M %p')
                    e['end_time'] = event.end_time.strftime('%I:%M %p')
                    e['meeting_time'] = event.meeting_time.strftime('%I:%M %p')
                    e['description'] = event.description
                    rsvp = UserEvent.where("user_id=? and event_id=?", @@current_user.id, event.id).first
                    if rsvp
                        e['rsvp'] = rsvp.rsvp
                    else
                        e['rsvp'] = -1
                    end
                    upcomingEventsArray.push(e)
                end

            render :status=>200, :json=>{:success=>"1", :message=>"Success", :url=>"get_more_upcoming_events", :upcoming_events=>upcomingEventsArray}
            end

            def rsvp
                event = Event.find(params[:event_id])
                userEvent = UserEvent.where("user_id=? and event_id=?", @@current_user.id, event.id).first
                if userEvent == nil
                    rsvp = UserEvent.new
                    rsvp.user_id = @@current_user.id
                    rsvp.event_id = params[:event_id]
                    rsvp.rsvp = params[:status].to_i
                    rsvp.save
                else
                    userEvent.rsvp = params[:status].to_i
                    userEvent.save
                end
                render :status=>200, :json=>{:success=>"1", :url=>"rsvp", :message=>"RSVP updated"}
            end

            def get_feedbacks
                feedbacks = EventFeedback.where("event_id=? and approved=?", params[:event_id], true)
                feedback_array = []
                feedbacks.each do |f|
                    feedback = {}
                    feedback['user_name'] = f.user.name
                    feedback['user_feedback'] = f.feedback
                    feedback['user_thumb'] = f.user.profile_picture.url(:thumb)
                    feedback_array.push(feedback)
                end
                render :status=>200, :json=>{:success=>"1", :message=>"Success", :url=>"get_feedbacks", :feedbacks => feedback_array}
            end

            def add_feedback
                user_feedback = EventFeedback.where("user_id=? and event_id=?", @@current_user.id, params[:event_id]).first
                if user_feedback
                    user_feedback.feedback = params[:feedback]
                    user_feedback.save
                else
                    user_feedback = EventFeedback.new
                    user_feedback.user_id = @@current_user.id
                    user_feedback.event_id = params[:event_id]
                    user_feedback.feedback = params[:feedback]
                    user_feedback.approved = false
                    user_feedback.save
                    apn = ApnHelper::Apn.new
                    apn.delay(:priority => 1).feedbackUploaded(@@current_user.name.sub("_", " "), Event.find(params[:event_id]).name, params[:feedback], user_feedback.id)
                end
                render :status=>200, :json=>{:success=>"1", :message=>"Feedback submitted", :url=>"add_feedback"}
            end

            def approve_feedback
                e = EventFeedback.find(params[:id])
                e.approved = true
                e.save
                render :status=>200, :json=>{:success=>"1", :message=>"Success", :url=>"approve_feedback"}
            end

            def get_event_pictures
                pictures = EventPicture.where("event_id=? and approved=?", params[:event_id], true).order(:created_at)
                picturesArray = []
                pictures.each do |picture|
                    p = {}
                    p['large'] = picture.picture.url(:large)
                    p['medium'] = picture.picture.url(:medium)
                    p['thumb'] = picture.picture.url(:thumb)
                    picturesArray.push(p)
                end
                render :status=>200, :json=>{:success=>"1", :message=>"Success", :url=>"get_event_pictures", :pictures=>picturesArray}
            end

            def add_event_picture
                apn = ApnHelper::Apn.new
                count = params[:count].to_i
                for i in 1..count
                    image = Paperclip.io_adapters.for(params["picture#{i}"])
                    image.original_filename = @@current_user.name.sub(" ", "_") + ".gif"
                    e = EventPicture.new
                    e.user_id = @@current_user.id
                    e.event_id = params[:event_id]
                    e.approved = false
                    e.picture = image
                    e.save
                    apn.delay(:priority => 1).pictureUploaded(@@current_user.name.sub("_", " "), Event.find(params[:event_id]).name, e.picture.url(:medium), e.id)
                end
                render :status=>200, :json=>{:success=>"1", :message=>"Picture/s uploaded", :url=>"add_event_picture"}
            end

            def approve_picture
                e = EventPicture.find(params[:id])
                e.approved = true
                e.save
                render :status=>200, :json=>{:success=>"1", :message=>"Success", :url=>"approve_picture"}
            end

            def update_profile
                u = @@current_user
                u.name = params[:name].downcase.split.map(&:capitalize)*' '
                u.email = params[:email]
                u.mobile_no = params[:mobile]
                u.date_of_birth = params[:date_of_birth]
                u.gender = params[:gender]
                u.age_group_id = params[:age_group].to_i
                u.notify_new_events = params[:notify_new_events]
                render :status=>200, :json=>{:success=>"1", :message=>"Profile updated", :url=>"update_profile"}
            end

            def update_profile_picture
                #profile picture
                p = {}
                image = Paperclip.io_adapters.for(params[:profile_picture])
                image.original_filename = (@@current_user.name.sub! ' ', '_') + ".gif"
                p["profile_picture"] = image
                @@current_user.update_attributes(p)
                url = @@current_user.profile_picture.url(:medium)
                url = "http://localhost:3000/" + url if Rails.env.development?
                render :status=>200, :json=>{:success=>"1", :message=>"Success", :url=>"update_profile_picture", :profile_picture=>url}
            end

            def change_password
                if !@@current_user.valid_password?(params[:password])
                    return render :status=>200, :json=>{:success=>"0", :message=>"Invalid password"}
                end
                user = User.find_by_email(@@current_user.email)
                user.password = params[:new_password]
                user.save
                render :status=>200, :json=>{:success=>"1", :message=>"Password changed", :url=>"change_password"}
            end

            def forgot_password
                user = User.find_by_email(params[:email])
                if !user
                    return render :status=>200, :json=>{:success=>"0", :message=>"Invalid Email", :url=>"forgot_password"}
                end
                o = [('a'..'z'), ('0'..'9')].map { |i| i.to_a }.flatten
                password = (0...8).map { o[rand(o.length)] }.join
                user.password = password
                user.save
                UserMailer.forgot_password_email(user, password).deliver
                render :status=>200, :json=>{:success=>"1", :message=>"A temporary password has been sent to #{params[:email]}", :url=>"forgot_password"}
            end

            def about_us
                g = {}
                g['text'] = AboutUs.first.about_us
                g['picture'] = AboutUs.first.picture.url(:medium)
                render :status=>200, :json=>{:success=>"1", :message=>"Success", :url=>"about_us", :about_us=>g}
            end

            def contact_us
                contactsArray = []
                contacts = Contact.order(:name)
                contacts.each do |d|
                    g = {}
                    g['name'] = d.name
                    g['email'] = d.email
                    g['mobile'] = d.mobile
                    contactsArray.push(g)
                end
                render :status=>200, :json=>{:success=>"1", :message=>"Success", :url=>"contact_us", :contacts=>contactsArray}
            end

            def get_donations
                donationsArray = []
                donations = DonationText.where(view: true)
                donations.each do |d|
                    g = {}
                    g['title'] = d.title
                    g['description'] = d.description
                    g['goal'] = d.goal
                    g['contact_name'] = d.contact_name
                    g['contact_mobile'] = d.contact_mobile
                    donationsArray.push(g)
                end
                render :status=>200, :json=>{:success=>"1", :message=>"Success", :url=>"get_donations", :donations=>donationsArray}
            end

        end
    end
end