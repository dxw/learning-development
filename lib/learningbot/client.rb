module LearningBot
  class Client
    class << self
      attr_reader :slack_client, :breathe_client

      def configure
        @slack_client = Slack::Web::Client.new(token: Config.slack_api_token)
        @breathe_client = Breathe.new(Config.breathe_api_token)
      end

      def send_message_to_channel(channel_id)
        slack_client.chat_postMessage(channel: channel_id, text: 'testing')
      end

      def send_message_to_email(email, message)
        slack_client.chat_postMessage(
          channel: lookup_user(email).user.id,
          text: message,
        )
      end

      def lookup_user(email)
        # id is the Uxxx user id
        slack_client.users_lookupByEmail(email: email)
      end

      def get_users
        slack_client.users_list
      end

      def get_breathe_user_data
        # currently limited to avoid spam, removing this is good.
        # Add emails to this when testing
        our_emails = %w[]
        breathe_client
          .get_employees
          .select do |user|
            user['status'] == 'Current employee' &&
              our_emails.include?(user['email'])
          end
          .map do |user|
            { email: user.fetch('email'), user_id: user.fetch('id') }
          end
      end

      def get_training_spend(breathe_employee_id)
        costs_and_currencies = training_courses
          .select do |training|
            training['employee']['id'] == breathe_employee_id.to_i
          end
          .map do |course|
            {
              cost: course['cost'].to_f,
              currency: breathe_client.get_currency(course['remuneration_currency_id']),
            }
          end

        total = 0

        costs_and_currencies.each { |x| 
          cost_in_gbp = (x[:cost].to_f * x[:currency][:exchange_rate].round(2))
          total += cost_in_gbp
        }

        total
      end

      def training_courses
        @training_courses ||= breathe_client.get_training
      end
    end
  end
end
