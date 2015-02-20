class Webhook
  DEFAULT_CHANNEL = "fuckallemaal"
  DEFAULT_USERNAME = "slackbot"

  attr_accessor :hook

  def initialize(attributes = {})
    options = {
      channel: (attributes[:channel] || DEFAULT_CHANNEL),
      username: (attributes[:username] || DEFAULT_USERNAME),
    }

    self.hook = Tarumi::Bot.new(
      SlackIntegrations::ZEUS_TEAM,
      SlackIntegrations::ZEUS_TOKEN,
      options
    )
  end

  def ping(text)
    self.hook.ping(text)
  end
end
