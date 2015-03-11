class CammieController < ApplicationController
  require 'open-uri'
  require 'fileutils'

  CAMMIEDIRECTORY = %w[cammie]

  skip_before_filter :verify_authenticity_token, :only => [:shoot]

  def shoot
    time = Time.now.strftime('%Y%m%d%H%M%S')
    filename = "host-#{time}.jpeg"
    filepath = [CAMMIEDIRECTORY, filename].join('/')

    open(['public', filepath].join('/'), 'wb') do |file|
      file << open('https://kelder.zeus.ugent.be/webcam/image/jpeg.cgi', {ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE}).read
    end

    webhook.ping("#{request.protocol}#{request.host_with_port}/#{filepath}")
    render json: { text: cammie_params[:channel_name] }
  end

  private

    def cammiedir
      FileUtils::mkdir_p CAMMIEDIRECTORY
    end

    def webhook
      Webhook.new(channel: "@benji", username: "testbot",
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
