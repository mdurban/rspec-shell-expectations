#!/usr/bin/env ruby
require 'socket'

name = ARGV.shift
port = ARGV.shift

sock = TCPSocket.new('localhost', port)
call_from_client = {
  command: name,
  stdin:   STDIN.tty? ? '' : $stdin.read,
  args:    ARGV
}
sock.write(Marshal.dump(call_from_client))
sock.close_write
conf_from_server = Marshal.load(sock.read)
sock.close_read

exit 0 if conf_from_server.empty?

(conf_from_server[:outputs] || []).each do |target, data|
  if target == :stdout
    $stdout.print data[:content]
    next
  end
  if target == :stderr
    $stderr.print data[:content]
    next
  end
  Pathname.new(target).open('w') do |f|
    f.print data[:content]
  end
end
exit conf_from_server[:exitcode] || 0
