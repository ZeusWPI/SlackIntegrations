require "uri"
require "net/http"

class QuotesController < ApplicationController
  respond_to :html

  def index
    @quotes = Quote.order('id DESC').all

    @new_quote = Quote.new
  end

  def create
    puts params
    @quote = Quote.new quote_params

    @quote.save
    render plain: 'Quote created!'
  end

  def show
    text = params[:text]

    if numeric?(params[:text])
      id = params[:text].to_i

      @quote = Quote.find_by(id: id)
      if !@quote.nil?
        call_webhook(params, @quote)
        render plain: "Komt eraan!"
        return
      end
    end

    @quotes = Quote.where('text like ?', "%#{params[:text]}%")
    if !@quotes.empty?
      call_webhook(params, @quotes.shuffle.first)
      render plain: "Komt eraan!"
    else
      render plain: 'Oei der zijn der zo geen!'
    end
  end

  private
    def call_webhook(params, quote)
      options = { icon_emoji: random_emoji,
                  channel:    "##{params[:channel_name]}",
                  username:   ZeusQuotes::QUOTES_BOTNAME
                }
      poster = Tarumi::Bot.new(ZeusQuotes::QUOTES_TEAM,
                               ZeusQuotes::QUOTES_TOKEN,
                               options)
      puts options.to_json
      poster.ping("@#{params[:user_name]} quoted \"#{quote.text}\"")
    end

    def quote_params
      params.require(:quote).permit(:token,
                                    :team_id,
                                    :channel_id,
                                    :channel_name,
                                    :user_id,
                                    :user_name,
                                    :command,
                                    :text)
    end

    def random_emoji
      [':suspect:', ':rage1:', ':goberserk:', ':godmode:', ':rage2:',
       ':rage3:', ':hurtrealbad:', ':rage4:', ':feelsgood:', ':finnadie:'].shuffle.first
    end

    # Whats a rails project without a stuckoverflow copy paste?
    # http://stackoverflow.com/questions/5661466/test-if-string-is-a-number-in-ruby-on-rails
    def numeric?(str)
      return true if str =~ /^\d+$/
      true if Float(str) rescue false
    end
end
