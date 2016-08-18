json.extract! lesson, :id, :name, :date, :status, :implementer_request_id, :created_at, :updated_at
json.url lesson_url(lesson, format: :json)