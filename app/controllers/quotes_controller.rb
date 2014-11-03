class QuotesController < ApplicationController
  def index
    @quotes = Quote.all

    @new_quote = Quote.new
  end
end
