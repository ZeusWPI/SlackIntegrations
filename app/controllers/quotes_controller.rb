class QuotesController < ApplicationController
  def index
    @quotes = Quote.all

    @new_quote = Quote.new
  end

  def create
    puts params
    redirect_to root_url
  end
end
