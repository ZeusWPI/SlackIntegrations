require 'json'
require 'open-uri'

class RestoController < ApplicationController
  skip_before_filter :verify_authenticity_token

  DAYS = {
    'morgen'     => 1.day,
    'overmorgen' => 2.days
  }

  def resto
    weekmenu = JSON.load(open("https://zeus.ugent.be/hydra/api/1.0/resto/week/#{Time.now.strftime("%U").to_i + 1}.json"))

    day = Time.now + (DAYS[params[:text]] || 0)
    if [0,6].include? day.strftime("%w").to_i
      render plain: "Resto is niet open in het weekend."
      return
    end

    menu = weekmenu[day.strftime("%Y-%m-%d")]

    unless menu
      render plain: "Menu is niet beschikbaar voor deze dag."
      return
    end

    if menu['open']
      text = '```'
      text << '*Soep*'
      text << '\r'
      text << maaltijd(menu['soup'])
      text << '\r'

      text << '*Hoofdgerecht*'
      text << '\r'
      text << maaltijden(menu['meat'])
      text << '\r'
      text << '*Groenten*'
      text << '\r'
      text << maaltijden(menu['vegetables'])
      text << '```'
    else
      text = "Resto is #{DAYS.has_key?(params[:text]) ? params[:text] : "vandaag" } niet open."
    end

    render plain: text
  end

  private

    def maaltijden(hash)
      hash.map{ |row| maaltijd(row) }.join('\r')
    end

    def maaltijd(hash)
      "#{hash['name']} - #{hash['price']}"
    end
end
