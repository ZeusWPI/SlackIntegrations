class RestoController < ApplicationController
  require 'json'
  require 'open-uri'

  def resto
    menu = JSON.load(open("https://zeus.ugent.be/hydra/api/1.0/resto/week/#{Time.now.strftime("%U").to_i + 1}.json"))[Time.now.strftime("%Y-%m-%d")]
    menu.symbolize_keys!

    out = {}
    if menu[:open]
      meals = menu[:meat].map{ |row| row["name"] }
      meals << menu[:soup]["name"]
      meals << menu[:vegetables]
      out[:text] = meals.join(', ')
    else
      out[:text] = "Resto is not open today"
    end

    render plain: out[:text]
  end
end
