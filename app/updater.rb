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

		start
	end

	def tracker
		@tracker ||= -> {
			next @tracker.after(1) unless Application.mumble?

			map = Application.mumble.identity[:map_id]

			if @map == map
				next @tracker.after(1)
			end

			Application.map = case map
			                  when Map::Eternal.id then :eternal
			                  when Map::Red.id     then :red
			                  when Map::Green.id   then :green
			                  when Map::Blue.id    then :blue
			                  end

			@map = map
			@tracker.after(1)
		}
	end

	def match
		@match ||= -> {
			next @match.after(Application.interval) unless Application.world

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
				@match.after(Application.interval)
			}
		}
	end

	def start
		tracker.after(1)
		match.after(Application.interval)
	end
end
