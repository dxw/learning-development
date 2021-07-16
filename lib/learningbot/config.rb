module LearningBot
  class Config
    class << self
      attr_reader :slack_api_token, :breathe_api_token

      def configure
        @slack_api_token = ENV['SLACK_BOT_USER_OAUTH_TOKEN']
        @breathe_api_token = ENV['BREATHE_PRODUCTION_API_KEY']
        self
      end
    end
  end
end