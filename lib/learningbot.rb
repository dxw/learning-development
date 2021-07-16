require 'dotenv/load'
require 'slack_ruby_client'
require_relative './learningbot/client'
require_relative './learningbot/config'
require_relative '../breathe'
module LearningBot
  def self.configure
    Config.configure
    Client.configure
  end
end

LearningBot.configure

MESSAGES = {jan: "Happy new year! Any new resolutions to learn something new?
There's £%0.2f available for you to spend on your learning and development.
See the playbook for more information on how to make use of it.
https://playbook.dxw.com/#personal-learning-and-development-allowance",
may: "You've still got £%0.2f available to spend on your learning and development,
but it'll refresh at the end of June. See the playbook for more details.
https://playbook.dxw.com/#personal-learning-and-development-allowance",
sept: "The kids are heading back to school. Any thoughts about your own learning?
There's £%0.2f in your learning and development pot -- ask your line manager if you're stumped how to spend it!
https://playbook.dxw.com/#personal-learning-and-development-allowance"
}


# p LearningBot::Client.get_training_spend
breathe_users = LearningBot::Client.get_breathe_user_data.map
breathe_users.each {|breathe_user|
  p breathe_user
  training_spend = LearningBot::Client.get_training_spend(breathe_user[:user_id])
  allowance_remaining = 1000 - training_spend
  message = MESSAGES[:sept] % allowance_remaining
  LearningBot::Client.send_message_to_email(breathe_user[:email], message)
}