
require "faraday"
require "json"
require "dotenv/load"
require "google/apis/sheets_v4"
require "googleauth"
require "breathe"

#require "./breathe"

#breathe = Breathe.new(ENV["BREATHE_PRODUCTION_API_KEY"])

breathe = Breathe::Client.new(api_key: ENV["BREATHE_PRODUCTION_API_KEY"], auto_paginate: true)

employee_training_courses = breathe.employee_training_courses.list
range_data = []


employee_training_courses.each_with_index.map { |course, i| 

  #currency = breathe.get_currency(course['remuneration_currency_id']);
  employee = breathe.employees.get(course.dig(:employee, :id))

  row_data = {
    department: employee&.dig(:department, :name),
    type: course.dig(:company_training_type, :name),
    category: course.dig(:company_training_category, :name),
    training_title: course.dig(:name),
    #currency: currency[:code],
    cost: course[:cost],
    #cost_in_gbp: (course['cost'].to_f * currency[:exchange_rate]).round(2),
    starts_on: course[:start_on],
    ends_on: course[:end_on],
    expires_on: course[:expires_on],
    notes: course[:notes]
  }

  break if i > 1

  range_data << row_data.values
}

p 'y'
exit

service = Google::Apis::SheetsV4::SheetsService.new

service.client_options.application_name = "dxw L&D"
service.authorization = Google::Auth::ServiceAccountCredentials.make_creds(
  json_key_io: StringIO.new(ENV.fetch("GOOGLE_CLIENT_SECRET")),
  scope: Google::Apis::SheetsV4::AUTH_SPREADSHEETS
)
spreadsheet_id = '1Z_EDcQjlcUkDecnZVz9_VFT7ZHddoiEv8o3g1PCt_mw'
range = "Sheet1!A2:ZZ"
response = service.update_spreadsheet_value(spreadsheet_id, range, Google::Apis::SheetsV4::ValueRange.new(values: range_data), value_input_option: 'USER_ENTERED')

puts response.to_json