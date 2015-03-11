class CammieController < ApplicationController
  require 'open-uri'
  require 'fileutils'

  CAMMIEDIRECTORY = %w[system cammie]

  skip_before_filter :verify_authenticity_token, :only => [:shoot]

  def shoot
    cammiedir

    time = Time.now.strftime('%Y%m%d%H%M%S')
    filename = "shot-#{time}.jpeg"
    filepath = [CAMMIEDIRECTORY, filename].join('/')

    open(['public', filepath].join('/'), 'wb') do |file|
      file << open('https://kelder.zeus.ugent.be/webcam/image/jpeg.cgi', {ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE}).read
    end

    webhook.ping("#{request.protocol}#{request.host_with_port}/slackintegrations/#{filepath}")
    render plain: ''
  end

  private

    def cammiedir
      FileUtils::mkdir_p ['public', CAMMIEDIRECTORY].join('/')
    end

    def webhook
      channel_name = cammie_params[:channel_name] == "directmessage" ? "#general" : "##{cammie_params[:channel_name]}"
      Webhook.new(channel: channel_name, username: "cammie",
                  icon_emoji: ":ghost:")
    end

    def cammie_params
      params.permit(:token,
                    :team_id,
                    :channel_id,
                    :channel_name,
                    :user_id,
                    :user_name,
                    :command,
                    :text)
    end
end
