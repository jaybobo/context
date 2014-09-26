require_relative 'config/environment'

$SERVER_LOG = Logger.new('logs/server.log', 'monthly')

#Name for the pid file, this file will store the process id of the process we fork
PID_FILE = "context.pid"

if File.exists?(PID_FILE)
  puts "A pid file already exists. This might mean the server is still running."
  puts "Check to see if a process with the pid in #{PID_FILE} exists and kill it."
  puts "When you are sure there is no old server process running, delete #{PID_FILE} and re-run."
end

#Process.daemon forks off a new process and exits the parent process
#The code after "Process.daemon" runs in the detached child process
#The first argument says "don't change directory"
#The second argument says "put STDOUT input (e.g. puts statements) out to the screen"

#In practice you want STDOUT and STDERR to be redirected to a log file so you can
#see what your daemon process is doing. In that case, the second argument would be
# false (or just don't supply it), you'd redirect STDOUT/STDERR yourself to a file (or files)

Process.daemon(true, true)

#Get my pid. This will be the child process' pid because `Process.daemon` forked us off by now and killed the parent
pid = Process.pid.to_s

#Write it out to the filesystem
File.write(PID_FILE, pid)


#If we get kill signal (as in `kill 40141`, CTRL-C, `exit()`, etc) we need to do some cleanup.
#You can trap the kill signal and do stuff before you shutdown completely.
#In this case, we need to stop the event loop and delete the PID file to make a clean exit
Signal.trap('EXIT') do
  begin
    EM.stop
  rescue
  end
  File.delete(PID_FILE)
  puts "Stopped Server\n"
end


class ChatRoom
  def initialize
    @clients = []
    @pg = PG::EM::Client.new dbname: 'context'
  end

  def start(options)
    EM::WebSocket.start(options) do |ws|
      ws.onopen { add_client(ws) }
      ws.onmessage { |msg| handle_message(ws, msg) }
      ws.onclose { remove_client(ws) }
    end
  end

  def add_client(ws)
    @clients << ws
    # puts "added #{ws}"
    # puts @clients.inspect
    # puts "length of @clients is #{@clients.length}"
  end

  def remove_client(ws)
    client = @clients.delete(ws)
    # puts "removed #{ws}"
  end

  def handle_message(ws, msg)
    Fiber.new {
      msg = ::JSON.parse(msg)
      @pg.query("INSERT INTO messages (content) VALUES ('#{msg["message"]}')") do |result|
      end
    }.resume

    send_all(msg["message"])
  end

  def send_all(msg)
    @clients.each do |ws|
      ws.send(msg)
    end
  end
end

chatroom = ChatRoom.new
EM.run {
  chatroom.start(host: "0.0.0.0", port: 8080)
}

# EM.run {
#   EM::WebSocket.run(:host => "0.0.0.0", :port => 8080) do |ws|
#     ws.onopen { |handshake|
#       $SERVER_LOG.debug("Websocket connection opened.")

#       # Access properties on the EM::WebSocket::Handshake object, e.g.
#       # path, query_string, origin, headers

#       # Publish message to the client
#       ws.send "Welcome!"
#     }

#     ws.onclose { $SERVER_LOG.debug("Websocket connection closed.") }

#     ws.onmessage { |msg|
#       puts "begin fiber"
#       Fiber.new {
#         # pg_db.add_message(content: msg) do |result|
#         #   sleep 5
#         #   p result
#         # end
#         # pg_db.query_messages_table
#         puts "before query"
#         pg.query("INSERT INTO messages (content) VALUES ('#{msg}')") do |result|
#           puts "in callback"
#           sleep 3
#           p result
#         end
#         puts "after query"
#         # EM.stop
#       }.resume

#       p "outside fiber"
#       $SERVER_LOG.debug("Received message: #{msg}")
#       ws.send "Pong: #{msg}"
#     }
#   end
# }
