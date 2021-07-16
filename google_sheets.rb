require "dotenv/load"
require "google/apis/sheets_v4"
require "googleauth"
require "breathe"

# Currency lookup
# TODO: get live-ish exchange rates
def get_currency(currency_id)
  {
    1 => {code: 'GBP', exchange_rate: 1.00},
    5 => {code: 'AUD', exchange_rate: 0.54},
    11 => {code: 'CAD', exchange_rate: 0.58},
    17 => {code: 'EUR', exchange_rate: 0.85},
    41 => {code: 'USD', exchange_rate: 0.72}
  }[currency_id]
end

# Access Breathe API
breathe = Breathe::Client.new(api_key: ENV["BREATHE_PRODUCTION_API_KEY"], auto_paginate: true)

# Get all employees' departments
employees = breathe.employees.list.response.data[:employees]

employees_departments = {}
employees.each { |employee|
  employees_departments[employee[:id]] = employee.to_h.dig(:department, :name)
}

# Get all training records
employee_training_courses = breathe.employee_training_courses.list.response.data[:employee_training_courses]
range_data = []

employee_training_courses.each_with_index.map { |course, i|
  course = course.to_h

  currency = get_currency(course[:remuneration_currency_id])

  row_data = {
    employee: course.dig(:employee, :id),
    department: employees_departments[course.dig(:employee, :id)],
    type: course.dig(:company_training_type, :name),
    category: course.dig(:company_training_category, :name),
    training_title: course.dig(:name),
    currency: currency[:code],
    cost: course[:cost],
    cost_in_gbp: (course[:cost].to_f * currency[:exchange_rate]).round(2),
    starts_on: course[:start_on]&.to_date,
    ends_on: course[:end_on]&.to_date,
    expires_on: course[:expires_on]&.to_date
  }

  range_data << row_data.values
}

# Push to Google Sheets
service = Google::Apis::SheetsV4::SheetsService.new
service.client_options.application_name = "dxw L&D"
service.authorization = Google::Auth::ServiceAccountCredentials.make_creds(
  json_key_io: StringIO.new(ENV.fetch("GOOGLE_CLIENT_SECRET")),
  scope: Google::Apis::SheetsV4::AUTH_SPREADSHEETS
)
spreadsheet_id = ENV["GOOGLE_SHEET_ID"]
range = "Sheet1!A2:ZZ"
response = service.update_spreadsheet_value(spreadsheet_id, range, Google::Apis::SheetsV4::ValueRange.new(values: range_data), value_input_option: 'USER_ENTERED')

puts response.to_json
