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
	attr_accessor :world, :interval

	def initialize(world, interval)
		@world    = world
		@interval = interval

		@block = -> {
			unless @world
				next @block.after(@interval)
			end

			epoch = Time.now.to_i

			Matches.find(@world).then {|match|
				match.details
			}.then {|details|
				Promise.when details.green, details.blue, details.red, details.eternal
			}.then {|maps|
				maps.each {|details|
					map = Map.const_get(details.name.capitalize).new

					details.objectives.each {|remote|
						local = map[remote.id]

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
				@block.after(@interval)
			}
		}

		@block.call
	end
end
