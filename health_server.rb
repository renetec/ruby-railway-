#!/usr/bin/env ruby

# Standalone health server that runs independently of Rails
require 'webrick'
require 'json'

puts "Starting standalone health server on port 8080..."

server = WEBrick::HTTPServer.new(
  Port: 8080,
  Logger: WEBrick::Log.new('/dev/null'),
  AccessLog: []
)

server.mount_proc '/health' do |req, res|
  res.status = 200
  res['Content-Type'] = 'application/json'
  res.body = JSON.generate({
    status: 'ok',
    timestamp: Time.now.iso8601,
    server: 'standalone_health'
  })
end

server.mount_proc '/' do |req, res|
  res.status = 200
  res['Content-Type'] = 'text/plain'
  res.body = 'Health server running'
end

trap('INT') { server.shutdown }
trap('TERM') { server.shutdown }

server.start