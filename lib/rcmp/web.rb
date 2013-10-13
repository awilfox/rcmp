require 'json'
require 'sinatra/base'

module RCMP
  class Web < Sinatra::Base
    def dispatch(params)
      begin
        payload = JSON.parse(params[:payload])
      rescue JSON::ParserError
        halt 400, 'invalid payload'
      end

      type = [GitHub].find {|type| type.detect(payload) }
      halt 400, 'unknown payload type' unless type

      params[:server] ||= 'default'
      server = Configru.irc.servers[params[:server]]
      server ||= Configru.irc.servers.find do |n, s|
        s['address'] == params[:server] ||
          s['alias'] == params[:server] ||
          s['alias'].include?(params[:server])
      end[1]
      halt 400, 'unknown server' unless server

      if params[:channel]
        channel = '#' + params[:channel]
      else
        channel = server['channel']
      end

      IRC[server].announce do |irc|
        irc.join(channel) unless irc.channels.include? channel
        Channel(channel).msg(type.format(payload))
      end
    end

    ['/:server/:channel', '/:channel', '/'].each do |route|
      post route do
        dispatch(params)
        'success'
      end
    end

    get '/' do
      'pong'
    end
  end
end
