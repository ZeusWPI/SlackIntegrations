class Webhook
  DEFAULT_CHANNEL = "fuckallemaal"
  DEFAULT_USERNAME = "slackbot"

  attr_accessor :hook

  def initialize(attributes = {})
    options = {
      channel:    (attributes[:channel] || DEFAULT_CHANNEL),
      username:   (attributes[:username] || DEFAULT_USERNAME),
      icon_url:   attributes[:icon_url],
      icon_emoji: attributes[:icon_emoji]
    }

    self.hook = Tarumi::Bot.new(
      SlackIntegrations::ZEUS_TEAM,
      Rails.application.secret.zeus_token,
      options
    )
  end

  def ping(text)
    self.hook.ping(text)
  end
end
