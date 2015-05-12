class CammieController < ApplicationController
  require 'open-uri'
  require 'fileutils'
  require 'net/http'
  require 'RMagick'
  include CammieHelper
  include Magick

  skip_before_filter :verify_authenticity_token, :only => [:shoot, :doorshot]

  CAMMIEDIRECTORY = %w[system cammie screenshots]

  def shoot
    make_dir ['public', CAMMIEDIRECTORY].join('/')

    time = Time.now.strftime('%Y%m%d%H%M%S')
    filename = "shot-#{time}.jpeg"

    filepath = [CAMMIEDIRECTORY, filename].join('/')
    snapshot ['public', filepath].join('/')

    render plain: "<#{request.protocol}#{request.host_with_port}/slackintegrations/#{filepath}>"
  end

  def doorshot
    move_cammie_to "door"

    time = Time.now.strftime('%Y%m%d%H%M%S')
    directory_without_system = ['system', 'cammie', 'door', time].join('/')
    directory_with_system = ['public', directory_without_system].join('/')
    make_dir directory_with_system

    pictures = []
    time_shot directory_with_system, 10, 1, pictures
    time_shot directory_with_system, 10, 5, pictures

    animation = ImageList.new
    pictures.each do |p|
      animation.push Image.read(p).first
    end
    animation.delay = 20
    animation.write([directory_with_system, "animated.gif"].join('/'))

    render plain: "#{request.protocol}#{request.host_with_port}/slackintegrations/#{[directory_without_system, "animated.gif"].join('/')}"
  end

  private

    def make_dir(directory)
      FileUtils::mkdir_p directory
    end

    def time_shot(directory, times, delay, pictures)
      times.times do
        time = Time.now.strftime('%Y%m%d%H%M%S')
        filepath = [directory, time + '.jpeg'].join('/')
        snapshot filepath
        pictures.push filepath
        sleep delay
      end
    end

    def move_cammie_to(preset_index)
      uri = URI("http://kelder.zeus.ugent.be/webcam/cgi/ptdc.cgi")
      Net::HTTP.post_form(uri, 'command' => 'goto_preset_position', 'index' => preset_index)
    end

    def webhook
      channel_name = cammie_params[:channel_name] == "directmessage" ? "@#{cammie_params[:user_name]}" : "##{cammie_params[:channel_name]}"
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
