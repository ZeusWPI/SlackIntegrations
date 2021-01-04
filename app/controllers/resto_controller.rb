require 'json'
require 'open-uri'

class RestoController < ApplicationController
  skip_before_action :verify_authenticity_token

  DAYS = {
    'morgen'     => 1.day,
    'overmorgen' => 2.days
  }.freeze

  def resto
    day = Time.now + (DAYS[params[:text]] || 0)
    if [0, 6].include? day.strftime('%w').to_i
      render plain: 'Resto is niet open in het weekend.'
      return
    end

    weekmenu = JSON.load(open("https://zeus.ugent.be/hydra/api/1.0/resto/menu/#{day.strftime('%Y')}/#{day.strftime('%V').to_i}.json"))

    menu = weekmenu[day.strftime('%Y-%m-%d')]

    unless menu
      render plain: 'Menu is niet beschikbaar voor deze dag.'
      return
    end

    if menu['open']
      text = ''
      text << (Time.now + (DAYS[params[:text]] || 0)).strftime('%d-%m') << "\n" if DAYS.key? params[:text]
      text << '*Soep*'
      text << "\n"
      text << maaltijd(menu['soup'])
      text << "\n"

      text << '*Hoofdgerecht*'
      text << "\n"
      text << maaltijden(menu['meat'])
      text << "\n"
      text << '*Groenten*'
      text << "\n"
      text << menu['vegetables'].join("\n")
    else
      text = "Resto is #{DAYS.key?(params[:text]) ? params[:text] : 'vandaag'} niet open."
    end

    render plain: text
  end

  private

  def maaltijden(hash)
    hash.map { |row| maaltijd(row) }.join("\n")
  end

  def maaltijd(hash)
    "#{hash['name']} - #{hash['price']}"
  end
end
