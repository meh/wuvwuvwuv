#--
#            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#                    Version 2, December 2004
#
#            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#   TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION
#
#  0. You just DO WHAT THE FUCK YOU WANT TO.
#++

class Updater
	attr_reader   :world
	attr_accessor :interval

	def initialize
		@maps   = Map.all
		@mumble = nil
		@map    = nil

		tracker
		match
	end

	def tracker
		names = {
			Map::Eternal.id => :eternal,
			Map::Red.id     => :red,
			Map::Green.id   => :green,
			Map::Blue.id    => :blue
		}

		-> {
			next unless Application.mumble?
			next unless Application.world
			next if (map = Application.mumble.identity[:map_id]) == @map

			Application.map = names[@map = map]
		}.every 1
	end

	def match
		-> {
			next match unless Application.world

			epoch = Time.now.to_i

			Matches.find(Application.world).then {|match|
				if Application.state[:match] != match.hash
					Application.state[:match] = match.hash

					@maps.each(&:clear)
				end

				match.details
			}.then {|details|
				details.maps.each {|d|
					map = @maps.find { |m| m.name == d.name }

					d.objectives.each {|remote|
						local = map[remote.id]
						local.reload

						unless local.guild.nil? && remote.guild!.nil?
							if remote.guild!.nil?
								local.guild = nil
								local.save
							elsif local.guild.nil? || local.guild.id != remote.guild!
								remote.guild.then {|guild|
									local.commit {
										local.guild = guild
									}
								}
							end
						end

						if remote.owner != local.owner
							if local.owner != :neutral
								local.capped = epoch - 5
							end

							local.owner     = remote.owner
							local.tier      = 0
							local.refreshed = 0

							local.save
						end
					}
				}
			}.always {|e|
				match
			}
		}.after Application.interval
	end
end
