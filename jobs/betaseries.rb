require 'net/http'
require 'json'
require 'date'

user = 'YOUR_USERNAME'
key = 'YOUR_API_KEY'

SCHEDULER.every '12h', :first_in => 0 do |job|
  now = DateTime.now.strftime('%D')
  http = Net::HTTP.new('api.betaseries.com')
  response = http.request(Net::HTTP::Get.new("/planning/member/#{user}.json?key=#{key}"))

  episodes = JSON.parse(response.body)["root"]["planning"]
  
  shows = []
  if episodes

    episodes.each do|number,o|
      date = DateTime.strptime("#{o['date']}",'%s').strftime('%D')
      if date == now
        shows<<o
      end
    end

    count = shows.count
    if count == 0
      status = "no show today :("
    elsif count == 1
      status = "1 show today !"
    else
      status = "#{count} shows today \\o/"
    end

  end

  send_event('betaseries', { shows: shows, status: status})
end
