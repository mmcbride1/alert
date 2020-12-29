#!/usr/bin/env ruby

require 'net/smtp'

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

  def getconfig
    config = Config.new.config()
    return config
  end

  def buildmsg 
    content = File.read(@filename)
    encoded = [content].pack("m")
    config  = getconfig()

    # Credentials
    from = config[:from]
    user = config[:mail]
    pass = config[:pass]
    mesg = config[:mesg]

    # Message marker
    marker  = "AUNIQUEMARKER"

    # Message body
    body = <<-EOF 
    #{mesg}
    EOF

    # Message headers
    headers = <<-EOF
    From: #{from}
    To: #{user}
    Subject: Motion detected!
    MIME-Version: 1.0
    Content-Type: multipart/mixed; boundry = #{marker}
    --#{marker}
    EOF

    # Message action
    action = <<-EOF
    Content-type: text/plain
    Content-Transfer-Encoding:8bit

    #{body}
    --#{marker}
    EOF

    # Message attachment
    attachment = <<-EOF
    Content-Type: multipart/mixed; name = \"#{@filename}\"
    Content-Transfer-Encoding:base64
    Content-Disposition: attachment; filename = "#{@filename}"

    #{encoded}
    --#{marker}--
    EOF

    # Message
    message = headers + action + attachment
    return message
  end

  def sendmsg
    # Build message
    msg = buildmsg()
    # Send Message
    begin
      Net::SMTP.start('gmail.com', from, pass, :login) do |smtp|
        smtp.sendmail(msg, from, user)
      end
    rescue Exception => ex
      print "Exception occured: " + ex
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

  def deltevideo(file)
    path = @videos + "/#{file}"
    File.delete(path)
  end

  def sendalert(file)
    Email.new(file).sendmsg()
  end

end

