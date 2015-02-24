class FucksController < ApplicationController
  include ActionView::Helpers::TextHelper

  SLACKBOT = 'slackbot'
  FAKBOTKANAAL = 'C036UF6A2'

  skip_before_filter :verify_authenticity_token, :only => [:create]
  respond_to :html

  def index
    @fucks = Fuck.order('amount DESC').all

    @new_fuck = Fuck.new
  end

  def show
    name = Fuck.format(fuck_params[:text])

    fuck = Fuck.find_by_name(name.downcase)
    if fuck.nil?
      render json: { text: "No fuck given" }
    else
      render json: { text: "#{name} has been fucked #{pluralize(fuck.amount, 'time')}" }
    end
  end

  def create
      if fuck_params[:user_name].start_with? SLACKBOT
          render json: { }
          return
      end

      name = Fuck.format(fuck_params[:text])
      fuck = Fuck.find_by_name name.downcase
      fuck ||= Fuck.new name: name.downcase

      fucker = fuck.fuckers.build(user_id: fuck_params[:user_id])

      out = Hash.new
      if fuck_params[:channel_id] == FAKBOTKANAAL
        if fucker.save!
          plural = pluralize(fuck.reload.amount, 'time')
          out[:text] = "Fucked #{name} #{plural}"
        else
          out[:text] = "Failure"
        end
      else
        if fucker.save
          webhook.ping("<@#{fuck_params[:user_name]}> in <##{fuck_params[:channel_name]}>: #{fuck_params[:text]}")
        end
      end

      render json: out
  end

  def personalfucks
    out = {}
    fucks = Fucker.where(user_id: fuck_params[:user_id]).select('fuckers.*, count(fuck_id) as count').group(:fuck_id).limit(5).order('count').reverse_order.includes(:fuck).map{ |f| f.fuck.name }.join(', ')

    if fucks.empty?
      out[:text] = "#{fuck_params[:user_name]} gives no fuck."
    else
      out[:text] = "#{fuck_params[:user_name]} personal fucks: #{fucks}"
    end

    render json: out
  end

  private
    def fuck_params
      if params[:fuck]
        params.require(:fuck).permit(:token,
                      :team_id,
                      :channel_id,
                      :channel_name,
                      :user_id,
                      :user_name,
                      :text)
      else
        params.permit(:token,
                      :team_id,
                      :channel_id,
                      :channel_name,
                      :user_id,
                      :user_name,
                      :text)
      end
    end

    def webhook
      Webhook.new(channel: "#fakbotkanaal", username: "fakbot",
                  icon_url: "https://s3-us-west-2.amazonaws.com/slack-files2/avatars/2015-02-17/3746989870_08edb39c02fe4b2b2699_48.jpg")
    end
end
