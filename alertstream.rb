#!/usr/bin/env ruby

require 'net/smtp'
require 'rubygems'
require 'mailfactory'

# Class accesses configuration
class Configz

  # Get config
  def config()
     file = '/home/admin/alert/alert.conf'
     conf = eval(File.open(file) {|f| f.read})
     return conf
  end

end

# Class handles alert 
# message construction
class Email

  def initialize(filename)
    # Init video filename
    @filename = filename

    # Init configuration
    @config = Configz.new.config()

    # Init mail properties
    @from = @config[:from]
    @user = @config[:mail]
    @pass = @config[:pass]
  end

  def build_alert_msg
    # Setup message
    sub = "Subject: Motion detected!"
    msg = sub + "\n" + "This is an alert."

    # Build message
    smtp = Net::SMTP.new 'smtp.gmail.com', 587
    smtp.enable_starttls
    smtp.start('gmail.com', @from, @pass, :login)
    smtp.send_message msg, @from, @user
    smtp.finish
  end

  def build_vid_msg
    # Mailer
    mail = MailFactory.new()

    # Message setup
    mail.to      = @user
    mail.from    = @from
    mail.subject = "Motion detected!"
    mail.text    = "See fileshare for video log."

    # Attach video file
    mail.attach(@filename)

    # Send
    smtp = Net::SMTP.new 'smtp.gmail.com', 587
    smtp.enable_starttls
    smtp.start('gmail.com', @from, @pass, :login)
    smtp.sendmail(mail.to_s, @from, @user)
    smtp.finish
  end

end

# Class provides methods for
# alert stream
class Alert

  # Video folder
  @@config = Configz.new.config()
  @@videos = @@config[:vids]

  def getvideo
    video_file = nil
    Dir[@@videos + "/*"].each do |file|
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
    alert = Email.new(video_file)
    alert.build_vid_msg()
    # Required to send a second message with
    # separate config here because, for some reason,
    # gmail fails to send a notification when the
    # message is built with an attachment, 
    # rendering this process effectively useless.
    # The second mail triggers the notification.
    alert.build_alert_msg()
  end

end

