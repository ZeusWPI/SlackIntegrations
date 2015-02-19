class RestoController < ApplicationController
  require 'json'
  require 'open-uri'

  DAYS = {
    'morgen'     => 1.day,
    'overmorgen' => 2.days
  }

  def resto
    weekmenu = JSON.load(open("https://zeus.ugent.be/hydra/api/1.0/resto/week/#{Time.now.strftime("%U").to_i + 1}.json"))

    if DAYS.has_key? params[:text]
      day = Time.now + DAYS[params[:text]]
    else
      day = Time.now
    end

    menu = weekmenu[day.strftime("%Y-%m-%d")]

    if menu && menu['open']
      meals = menu['meat'].map{ |row| row['name'] }
      meals << menu['soup']['name']
      meals << menu['vegetables']
      text = meals.join(', ')
    else
      text = "Resto is not open today"
    end

    render plain: text
  end
end
