#!/usr/bin/env ruby

require 'net/smtp'

class WebCam

   # Store number of files in Video folder #

   @@filecount

   # Initializes the Video directory to read

   def initialize(f)

      @read = f

   end

   # Set or reset video file count

   def setcount(i)

      @@filecount = i

   end

   # Configuration for email params, etc.

   def config()

      n = '/etc/alert.conf'

      conf = eval(File.open(n) {|f| f.read})

      return conf

   end

   # Determine number of files in Video folder

   def getfilecount()

      cmd = `ls -1 #{@read} | wc -l`

      return cmd.to_i

   end

   # Send alert whenever new video is generated

   def email(sub)

      c = config()

      mesg = "Subject: #{sub}" + "\n" + c[:mesg]

      smtp = Net::SMTP.new 'smtp.gmail.com', 587

      smtp.enable_starttls

      smtp.start('gmail.com', c[:from], c[:pass], :login)

      smtp.send_message mesg, c[:from], c[:mail]

      smtp.finish     

   end

end
