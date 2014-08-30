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
		@maps  = Map.all
		@block = -> {
			next @block.after(Application.interval) unless Application.world

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
				@block.after(Application.interval)
			}
		}

		@block.call
	end
end
