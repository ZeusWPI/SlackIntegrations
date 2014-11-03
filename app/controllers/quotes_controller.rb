require "uri"
require "net/http"

class QuotesController < ApplicationController
  skip_before_filter :verify_authenticity_token, :only => [:create]
  respond_to :html

  def index
    @quotes = Quote.order('id DESC').all

    @new_quote = Quote.new
  end

  def create
    @quote = Quote.create quote_params

    call_add_quote_webhook(params, @quote)

    head :ok, content_type: "text/html"
  end

  def show
    text = params[:text]

    if numeric?(params[:text])
      id = params[:text].to_i

      @quote = Quote.find_by(id: id)
      if !@quote.nil?
        call_quote_webhook(params, @quote)
        head :ok, content_type: "text/html"
        return
      end
    end

    @quotes = Quote.where('text like ?', "%#{params[:text]}%")
    if !@quotes.empty?
      call_quote_webhook(params, @quotes.shuffle.first)
      head :ok, content_type: "text/html"
    else
      render plain: 'Oei der zijn der zo geen!'
    end
  end

  private
    def poster(params)
      is_dm = params[:channel_name] != 'directmessage'
      channel_name = is_dm ? "@#{params[:user_name]}" : "##{params[:channel_name]}"
      options = { icon_emoji: random_emoji,
                  channel:    channel_name,
                  username:   ZeusQuotes::QUOTES_BOTNAME
                }
      poster = Tarumi::Bot.new(ZeusQuotes::QUOTES_TEAM,
                               ZeusQuotes::QUOTES_TOKEN,
                               options)
    end
    def call_add_quote_webhook(params, quote)
      poster(params).ping("@#{params[:user_name]} added the quote “#{quote.text}”")
    end

    def call_quote_webhook(params, quote)
      poster(params).ping("@#{params[:user_name]} quoted “#{quote.text}”")
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

    def random_emoji
      [':skull:'].shuffle.first
    end

    # Whats a rails project without a stuckoverflow copy paste?
    # http://stackoverflow.com/questions/5661466/test-if-string-is-a-number-in-ruby-on-rails
    def numeric?(str)
      return true if str =~ /^\d+$/
      true if Float(str) rescue false
    end
end
