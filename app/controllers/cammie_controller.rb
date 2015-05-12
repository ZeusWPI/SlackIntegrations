class CammieController < ApplicationController
  require 'open-uri'
  require 'fileutils'
  require 'net/http'
  include CammieHelper

  skip_before_filter :verify_authenticity_token, :only => [:shoot, :doorshot]

  CAMMIEDIRECTORY = %w[system cammie screenshots]

  def shoot
    cammiedir

    time = Time.now.strftime('%Y%m%d%H%M%S')
    filename = "shot-#{time}.jpeg"

    filepath = [CAMMIEDIRECTORY, filename].join('/')
    snapshot ['public', filepath].join('/')

    render plain: "<#{request.protocol}#{request.host_with_port}/slackintegrations/#{filepath}>"
  end

  def doorshot
    move_cammie_to "door"

    time = Time.now.strftime('%Y%m%d%H%M%S')
    directory = ['public', 'system', 'cammie', 'door', time].join('/')
    make_dir directory

    10.times do
      time_shot directory
      sleep 1
    end

    10.times do
      time_shot directory
      sleep 5
    end

    render plain: "finished"
  end

  private

    def cammiedir
       make_dir ['public', CAMMIEDIRECTORY].join('/')
    end

    def make_dir(directory)
      FileUtils::mkdir_p directory
    end

    def time_shot(directory)
      time = Time.now.strftime('%Y%m%d%H%M%S')
      snapshot [directory, time + '.jpeg'].join('/')
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
