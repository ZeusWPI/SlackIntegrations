class FucksController < ApplicationController
  skip_before_filter :verify_authenticity_token, :only => [:create]
  respond_to :html

  def index
    @fucks = Fuck.order('amount DESC').all

    @new_fuck = Fuck.new
  end

  def show
    name = params[:text]

    @fuck = Fuck.find_by(name: name)
    if !@fuck.nil?
      call_webhook(params, @fuck)
      render plain: "Komt eraan!"
      return
    end
  end

  def create
      if fuck_params[:user_name].start_with? "slackbot"
          out = Hash.new
          out[:text] = ""
          render json: out
          return
      end

      name = fuck_params[:text].sub(/^[^ ]* /, '')

      fuck = Fuck.find_by_name name.titleize

      if !fuck.nil?
        fuck.amount += 1
      else
        fuck = Fuck.new name: name.titleize, amount: 1
      end

      out = Hash.new
      if fuck.save!
        out[:text] = "Fucked \"#{name}\" #{fuck.amount} times"
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
