
PRODUCTION_URL = 'https://api.breathehr.com:443/v1/'

class Breathe
  attr_reader :api_key

  def initialize(api_key)
    @api_key = api_key
  end

  def make_request(endpoint, parameters = {})
    response_body = Faraday.get(PRODUCTION_URL + endpoint, parameters, { 'X-API-KEY': api_key }).body
    JSON.parse(response_body)
  end

  def get_training
    page_number = 1
    employee_training_courses = []
    loop do
      data = make_request('employee_training_courses', { page: page_number })['employee_training_courses']
      page_number += 1
      employee_training_courses.concat(data)
      break if data.empty?
    end

    employee_training_courses
  end

  def get_employees
    page_number = 1
    employees = []
    loop do
      data = make_request('employees', { page: page_number })['employees']
      break if data.empty?
      page_number += 1
      employees.concat(data)
    end

    employees
  end

  def get_employee(employee_id)
    make_request("employees/#{employee_id}")['employees']&.first
  end

  def get_currency(currency_id)
    {
      1 => {code: 'GBP', exchange_rate: 1.00},
      41 => {code: 'USD', exchange_rate: 0.72},
      17 => {code: 'EUR', exchange_rate: 0.85},
      11 => {code: 'CAD', exchange_rate: 0.58},
      5 => {code: 'AUD', exchange_rate: 0.54}
    }[currency_id]
  end
end