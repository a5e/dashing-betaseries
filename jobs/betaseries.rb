require 'net/http'
require 'json'
require 'date'

# Fill your username and apikey here
username = 'YOUR_USERNAME'
apikey = 'YOUR_API_KEY'

# Set the number of episodes displayed
limit = 7

SCHEDULER.every '6h', :first_in => 0 do |job|

  http = Net::HTTP.new('api.betaseries.com')
  response = http.request(Net::HTTP::Get.new("/planning/member/#{username}.json?key=#{apikey}"))

  episodes = JSON.parse(response.body)["root"]["planning"]
  
  shows = []
  if episodes
    episodes.each do|number,episode|
      date = DateTime.strptime("#{episode['date']}",'%s')
      if (date > Date.today)
        episode['date'] = date.strftime('%d/%m')
        shows<<episode
      end
    end
  end

  send_event('betaseries', { shows: shows.take(limit) })
end
