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

	def initialize(world, interval)
		@world    = world
		@interval = interval
		@maps     = [Map::Green.new, Map::Blue.new, Map::Red.new, Map::Eternal.new]

		@block = -> {
			unless @world
				next @block.after(@interval)
			end

			epoch = Time.now.to_i

			Matches.find(@world).then {|match|
				if @id.nil?
					@id = match.id
				elsif @id != match.id
					@id = match.id
					@maps.each(&:clear)
				end

				match.details
			}.then {|details|
				[details.green!, details.blue!, details.red!, details.eternal!].each {|d|
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
				@block.after(@interval)
			}
		}

		@block.call
	end

	def world=(value)
		return unless value != @world

		@world = value
		@maps.each(&:clear)
	end
end
