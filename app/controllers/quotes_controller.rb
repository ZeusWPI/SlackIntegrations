require "uri"
require "net/http"

class QuotesController < ApplicationController
  skip_before_action :verify_authenticity_token, :only => [:create]
  respond_to :html

  def index
    @quotes = Quote.order('id DESC').all

    @new_quote = Quote.new
  end

  def create
    @quote = Quote.create quote_params

    call_add_quote_webhook(params, @quote)

    head :ok
  end

  def show
    if numeric?(params[:text])
      id = params[:text].to_i

      @quote = Quote.find_by(id: id)
      if !@quote.nil?
        call_quote_webhook(params, @quote)
        head :ok
        return
      end
    end

    @quotes = Quote.where('text like ?', "%#{params[:text]}%")
    if !@quotes.empty?
      call_quote_webhook(params, @quotes.shuffle.first)
      head :ok
    else
      render plain: "No such quote :'("
    end
  end

  private
    def poster(params, is_add)
      name = if not is_add then "#{params[:user_name]} quoted: " else "@#{params[:user_name]} added the quote " end
      is_dm = params[:channel_name] == 'directmessage'
      channel_name = is_dm ? "@#{params[:user_name]}" : "##{params[:channel_name]}"

      Webhook.new(channel: channel_name, username: name)
    end

    def call_add_quote_webhook(params, quote)
      poster(params, true).ping("“#{quote.text}”")
    end

    def call_quote_webhook(params, quote)
      poster(params, false).ping("“#{quote.text}”")
    end

    def quote_params
      if params.has_key? :quote
        params.require(:quote).permit(:token,
                                      :team_id,
                                      :channel_id,
                                      :channel_name,
                                      :user_id,
                                      :user_name,
                                      :command,
                                      :text)
      else
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

    # Whats a rails project without a stuckoverflow copy paste?
    # http://stackoverflow.com/questions/5661466/test-if-string-is-a-number-in-ruby-on-rails
    def numeric?(str)
      return true if str =~ /^\d+$/
      true if Float(str) rescue false
    end
end
