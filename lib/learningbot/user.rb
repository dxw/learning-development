module LearningBot
  class User
    attr_reader :user_id

    def initialize(user_id)
      @user_id = user_id
    end

    def name
      body['display_name']
    end

    def email
      body['email']
    end

    def slack_user_id
      slack_user['user']['id']
    end

    def send_reminder
      return if should_be_skipped?

      Config.slack_client.chat_postMessage(
        channel: slack_user_id,
        text: "Remember to use your L&D budget",
      )
    end

    private

    def should_be_skipped?
      slack_user.nil?
    end

    def slack_user
      @slack_user ||=
        begin
          Config.slack_client.users_lookupByEmail(email: email)
        rescue Slack::Web::Api::Errors::SlackError
          logger.info "No user found for #{email}"
          nil
        end
    end

    def body
      @body ||= Dug::Config.tenkft_client.users.get(user_id)
    end

    def logger
      @logger ||= Logger.new($stdout)
    end
  end
end
