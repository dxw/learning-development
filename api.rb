
require "faraday"
require "json"
require "dotenv/load"

SANDBOX_URL = 'https://api.sandbox.breathehr.info:443/v1/employee_training_courses'
PRODUCTION_URL = 'https://api.breathehr.com:443/v1/employee_training_courses'
TRAINING = 'employee_training_courses'
#  takes employee_id, page and (number of items) per_page, returns JSON
PRODUCTION_API_KEY = ENV["BREATHE_PRODUCTION_API_KEY"]

employee_training_courses = []


page_number = 1

loop do
  response_body = Faraday.get(PRODUCTION_URL, { page: page_number }, { 'X-API-KEY': PRODUCTION_API_KEY }).body
  data = JSON.parse(response_body)[TRAINING]
  page_number += 1
  employee_training_courses.concat(data)
  break if data.empty?
end

currencies = {
    1 => {code: 'GBP', exchange_rate: 1.00},
    41 => {code: 'USD', exchange_rate: 0.72},
    17 => {code: 'EUR', exchange_rate: 0.85},
    11 => {code: 'CAD', exchange_rate: 0.58},
    5 => {code: 'AUD', exchange_rate: 0.54}
}

courses = employee_training_courses.map {|x| 
  course_cost = x['cost'].to_f
  course_currency = currencies[x['remuneration_currency_id']]

  cost_in_pounds = course_cost * course_currency[:exchange_rate]
  name = x['name']
  category = x['company_training_category']
  type = x['company_training_type']

  {
    category: category&.fetch("name", "Not found"),
    type: type&.fetch("name", "Not found"),
    cost: cost_in_pounds,
    name: name
  }
}

output = Hash.new(0)

courses.group_by { |x| x[:category]}.each do |category, array|
  output[category] = array.reduce(0) { |sum, entry| sum + entry[:cost] }
end

p output
