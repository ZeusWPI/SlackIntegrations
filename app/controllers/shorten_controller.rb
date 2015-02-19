require 'json'
require 'open-uri'

class ShortenController < ApplicationController
  def shorten
    if params[:text].nil?
      render plain: "Please provide a url."
      return
    end

    url = "http://api.bit.ly/v3/shorten?" +
      "login=benjizeus" +
      "&apiKey=R_3e5099d410d44e9aa12e6c6b3b7cb896" +
      "&longUrl=#{ERB::Util.url_encode(prefix(params[:text]))}" +
      "&format=json"

    response = JSON.load(open(url))

    if response["status_code"] == 200 && response["status_txt"] == "OK"
      render plain: response["data"]["url"]
    else
      render plain: "Status code: #{response["status_code"]}"
    end
  end

  private

    def prefix(url)
      if url.start_with?('http://') || url.start_with?('https://')
        url
      else
        'http://' + url
      end
    end
end
