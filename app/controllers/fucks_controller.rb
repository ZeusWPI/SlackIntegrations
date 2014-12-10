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
    name = fuck_params[:text].split()[1]

    fuck = Fuck.find_by_name name

    if !fuck.nil?
      fuck.amount += 1
    else
      fuck = Fuck.new name: name, amount: 1
    end

    out = Hash.new
    if fuck.save!
      out[:text] = "Fuck counted"
    else
      out[:text] = "Failure"
    end

    render json: out
  end

  private
    def fuck_params
      params.require(:fuck).permit(:token,
                                   :team_id,
                                   :channel_id,
                                   :channel_name,
                                   :user_id,
                                   :user_name,
                                   :text)
    end
end
