class FucksController < ApplicationController
  include ActionView::Helpers::TextHelper

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
      render json: { }
    else
      render json: { text: "#{name} has been fucked #{pluralize(fuck.amount, 'time')}" }
    end
  end

  def create
      if fuck_params[:user_name].start_with? "slackbot"
          render json: { text: '' }
          return
      end

      name = Fuck.format(fuck_params[:text])
      fuck = Fuck.find_by_name name.downcase

      if fuck.nil?
        fuck = Fuck.new name: name.downcase, amount: 1
      else
        fuck.amount += 1
      end

      out = Hash.new
      if fuck.save!
        plural = pluralize(fuck.amount, 'time')
        out[:text] = "Fucked #{name} #{plural}"
      else
        out[:text] = "Failure"
      end

      render json: out
  end

  private
    def fuck_params
      if params.has_key? :fuck
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
end
