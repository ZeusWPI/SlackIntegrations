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

    render :ok, text: ""
  end

  def show
    text = params[:text]

    if numeric?(params[:text])
      id = params[:text].to_i

      @quote = Quote.find_by(id: id)
      if !@quote.nil?
        call_quote_webhook(params, @quote)
        render :ok, text: ""
        return
      end
    end

    @quotes = Quote.where('text like ?', "%#{params[:text]}%")
    if !@quotes.empty?
      call_quote_webhook(params, @quotes.shuffle.first)
      render :ok, text: ""
    else
      render :ok, text: "No such quote :'("
    end
  end

  private
    def poster(params)
      is_dm = params[:channel_name] == 'directmessage'
      channel_name = is_dm ? "@#{params[:user_name]}" : "##{params[:channel_name]}"
      options = { channel:    channel_name,
                  username:   params[:user_name]
                }
      poster = Tarumi::Bot.new(ZeusQuotes::QUOTES_TEAM,
                               ZeusQuotes::QUOTES_TOKEN,
                               options)
    end
    def call_add_quote_webhook(params, quote)
      poster(params).ping("@#{params[:user_name]} added the quote “#{quote.text}”")
    end

    def call_quote_webhook(params, quote)
      poster(params).ping(" quoted “#{quote.text}”")
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
