json.extract! employee, :id, :name, :telephone, :email, :work_type, :area_residence, :service_area, :coordination_skills, :implementation_skills, :appraisal_grade, :employee_type, :company_id, :created_at, :updated_at
json.url employee_url(employee, format: :json)