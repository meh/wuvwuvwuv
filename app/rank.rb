#--
#            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#                    Version 2, December 2004
#
#            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#   TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION
#
#  0. You just DO WHAT THE FUCK YOU WANT TO.
#++

class Rank
	def self.fetch(region)
		Browser::HTTP.get("https://leaderboards.guildwars2.com/en/#{region}/wvw") {|req|
			req.headers.clear
		}.then {|res|
			Hash[res.text.scan(%r{class=".*?rank number">[\s\S]*?>\s*(\d+)[\s\S]*?class="name text">\s*([\w ]+)}m).map {|id, name|
				[name.strip, id.to_i]
			}]
		}
	end
end
