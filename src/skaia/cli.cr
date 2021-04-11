module Skaia
  class CLI
    BANNER = "Skaia #{VERSION}, built with Crystal #{Crystal::VERSION}"
    MOTD   = <<-TXT

    /\\ /\\
    ( . .) #{BANNER}

    Starting processing, hit Ctrl-C to stop\n\n
    TXT

    Log = Skaia::Log.for(self)

    def initialize(args = ARGV, stream : IO::FileDescriptor = STDOUT)
      @consumers = [] of Skaia::Consumer
      @verbose = false

      OptionParser.parse(args) do |parser|
        parser.banner = BANNER

        parser.on("-w WORKER", "Worker to process") do |candidate|
          worker = REGISTERED_WORKERS.find { |r_worker| r_worker.name == candidate }
          if worker.nil?
            stream.puts "ERROR: #{candidate} is not a registered worker."
            exit(1)
          end

          @consumers << Skaia::Consumer.new(worker)
        end

        parser.on("-v", "--version", "Show the version number") { stream.puts(BANNER); exit }
        parser.on("-h", "--help", "Show this help") { stream.puts(parser); exit }

        parser.missing_option do |flag|
          stream.puts "ERROR: #{flag} flag expects a argument."
          exit(1)
        end

        parser.invalid_option do |flag|
          stream.puts "ERROR: #{flag} is not a valid option."
          exit(1)
        end
      end
    end

    def run
      STDOUT.puts(MOTD) if STDOUT.tty?

      signal = Channel(Nil).new

      Log.info { "starting" }

      server = Skaia::Server.new(@consumers)
      server.start

      {% for signal in %w[TERM INT] %}
        Signal::{{signal.id}}.trap do
          Log.info { "[SIG{{signal.id}}] received graceful stop" }
          server.stop
          signal.send(nil)
        end
      {% end %}

      signal.receive

      Log.info { "down" }
    end
  end
end
