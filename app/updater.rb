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

		start
	end

	def tracker
		@tracker ||= -> {
			next @tracker.after(1) unless Application.mumble?

			mumble = Application.mumble

			if @mumble && @mumble.identity[:map_id] == mumble.identity[:map_id]
				next @tracker.after(1)
			end

			Application.map = case mumble.identity[:map_id]
			                  when 38 then :eternal
			                  when 94 then :red
			                  when 95 then :green
			                  when 96 then :blue
			                  else         nil
			                  end

			@mumble = mumble
			@tracker.after(1)
		}
	end

	def match
		@match ||= -> {
			next @match.after(Application.interval) unless Application.world

			epoch = Time.now.to_i

			Matches.find(Application.world).then {|match|
				if Application.match != match.hash
					Application.match = match.hash

					@maps.each(&:clear)
				end

				match.details
			}.then {|details|
				details.maps.each {|d|
					map = @maps.find { |m| m.name == d.name }

					d.objectives.each {|remote|
						local = map[remote.id]
						local.reload

						if remote.owner != local.owner
							if local.owner != :neutral
								local.capped = epoch - 5
							end

							local.owner     = remote.owner
							local.guild     = nil
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
