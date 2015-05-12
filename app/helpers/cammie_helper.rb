module CammieHelper

  def snapshot(filepath)
    open(filepath, 'wb') do |file|
      file << open('https://kelder.zeus.ugent.be/webcam/image/jpeg.cgi').read
    end
  end
end
