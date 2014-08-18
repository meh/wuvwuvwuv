#--
#            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#                    Version 2, December 2004
#
#            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#   TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION
#
#  0. You just DO WHAT THE FUCK YOU WANT TO.
#++

class Configuration < Lissio::Component
	html do
		h1 'World'

		select(size: 3).world! do
			optgroup(label: 'North America') do
				Match::WORLDS.to_a.select {|id, name|
					id.to_s[0] == ?1
				}.sort_by {|_, name|
					name
				}.each {|id, name|
					option(value: id) do
						name
					end
				}
			end

			optgroup(label: 'Europe') do
				Match::WORLDS.to_a.select {|id, name|
					id.to_s[0] == ?2
				}.sort_by {|_, name|
					name
				}.each {|id, name|
					option(value: id) do
						name
					end
				}
			end
		end

		h1 'Map'

		select(size: 3).map! do
			option(value: :eternal) do
				'Eternal Battlegrounds'
			end

			option(value: :green) do
				'Green Border'
			end

			option(value: :blue) do
				'Blue Border'
			end

			option(value: :red) do
				'Red Border'
			end
		end

		h1.go('GO').on :click do
			world = $document['world'].value
			map   = $document['map'].value

			next unless world && map

			Application.world = world.to_i
			Application.map   = map

			if Overwolf.available?
				Overwolf::Window.open('TrackerWindow').then {|w|
					if w.visible?
						w.close

						Overwolf::Window.open('TrackerWindow').then {|w|
							w.restore
						}
					else
						w.restore
					end
				}.then {
					Overwolf::Window.current
				}.then {|w|
					w.minimize
				}.rescue {|e|
					$window.alert e.inspect
				}
			end
		end
	end

	css do
		text align: :center

		rule 'h1' do
			margin 6.px, 0

			rule '&.go' do
				cursor :pointer

				rule '&:hover' do
					style 'text-shadow',
						(', 0 0 2px #b20000' * 10)[1 .. -1] +
						(', 0 0 1px #b20000' * 10)
				end
			end
		end

		rule 'select' do
			margin bottom: 5.px
		end
	end
end
