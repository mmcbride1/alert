#!/usr/bin/env ruby

require 'net/smtp'
require 'rubygems'
require 'mailfactory'

# Class accesses configuration
class Config

  # Get config
  def config()
     file = 'alert.conf'
     conf = eval(File.open(file) {|f| f.read})
     return conf
  end

end

# Class handles alert 
# message construction
class Email

  def initialize(filename)
    @filename = filename
  end

  def buildmsg
    # Config
    config = Config.new.config()

    # Credentials
    from = config[:from]
    user = config[:mail]
    pass = config[:pass]
    mesg = config[:mesg]

    # Mailer
    mail = MailFactory.new()

    # Message setup
    mail.to      = user
    mail.from    = from
    mail.subject = "Motion detected!"
    mail.text    = "See fileshare for video log."

    # Attach video file
    mail.attach(@filename)

    # Send
    begin 
      smtp = Net::SMTP.new 'smtp.gmail.com', 587
      smtp.enable_starttls
      smtp.start('gmail.com', from, pass, :login)
      smtp.sendmail(mail.to_s, from, user)
      smtp.finish
    rescue Exception => ex
      print "Exception occured: " + ex.to_s + "\n"
    end
  end

end

# Class provides methods for
# alert stream
class Alert

  def initialize(video_dir)
    @videos = video_dir
  end

  def getvideo
    video_file = nil
    Dir[@videos + "/*"].each do |file|
      if file.end_with?(".avi")
        video_file = file
      end
    end
    return video_file
  end

  def deletevideo(video_file)
    File.delete(video_file)
  end

  def sendalert(video_file)
    Email.new(video_file).buildmsg()
  end

end

