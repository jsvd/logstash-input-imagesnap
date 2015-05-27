# encoding: utf-8
require "logstash/inputs/base"
require "logstash/namespace"
require "stud/interval"
require "socket" # for Socket.gethostname

class LogStash::Inputs::ImageSnap < LogStash::Inputs::Base

  config_name "imagesnap"

  default :codec, "plain"

  config :interval, :validate => :number, :default => 5

  def register; end

  def run(queue)
    Stud.interval(@interval) do
      system("imagesnap -w 2 /tmp/snapshot.jpg >> /dev/null 2>&1")
      system("sips -Z 320 /tmp/snapshot.jpg 2>&1 >> /dev/null 2>&1")
      image = IO.popen("cat /tmp/snapshot.jpg").read
      event = LogStash::Event.new("message" => image)
      decorate(event)
      queue << event
    end
  end

end # class LogStash::Inputs::Example
