class QuotesController < ApplicationController
  respond_to :html

  def index
    @quotes = Quote.all

    @new_quote = Quote.new
  end

  def create
    puts params
    @quote = Quote.new quote_params

    @quote.save
    redirect_to root_url
  end

  def show
    text = params[:text]
    if numeric?(params[:text])
      id = params[:text].to_i

      @quote = Quote.find_by(id: id)

      render plain: @quote.text if !@quote.nil?
      return
    end

    @quotes = Quote.where('text like ?', "%#{params[:text]}%")
    if !@quotes.empty?
      render plain: @quotes.shuffle.first.text
    else
      render plain: 'Oei der zijn der zo geen!'
    end
  end

  private
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

    # Whats a rails project without a stuckoverflow copy paste?
    # http://stackoverflow.com/questions/5661466/test-if-string-is-a-number-in-ruby-on-rails
    def numeric?(str)
      return true if str =~ /^\d+$/
      true if Float(str) rescue false
    end
end
