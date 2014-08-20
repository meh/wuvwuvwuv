#--
#            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#                    Version 2, December 2004
#
#            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#   TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION
#
#  0. You just DO WHAT THE FUCK YOU WANT TO.
#++

require 'opal'
require 'lissio'
require 'overwolf'

require 'browser/screen'
require 'browser/storage'
require 'browser/delay'
require 'browser/interval'
require 'browser/console'

require 'match'
require 'rank'
require 'configuration'
require 'map'
require 'map/green'
require 'map/blue'
require 'map/red'
require 'map/eternal'

class Application < Lissio::Application
	expose :@map

	def initialize(*)
		super

		router.fragment!

		route '/configuration' do
			load Configuration.new
		end

		route '/tracker' do
			load @map = Map.const_get(map.capitalize).new
			@map.start(storage(:timers).to_h, storage(:tiers).to_h)

			Match.find(world).then {|m|
				updater = -> {
					m.details.then {|d|
						epoch = Time.now.to_i

						[d.red, d.blue, d.green, d.eternal].each {|w|
							w.each {|o|
								id = o.id.to_s

								if storage(:timers).has_key? id
									owner, _ = storage(:timers)[id]

									if owner != o.owner
										storage(:timers)[id] = [o.owner, epoch]
										storage(:tiers).delete(id)
										storage(:sieges).delete(id)
									end
								else
									storage(:timers)[id] = [o.owner, 0]
								end
							}
						}

						@map.update(d)

						updater.after(2)
					}.rescue {|e|
						$console.log e.inspect
					}
				}

				updater.()
			}

			every 1 do
				@map.tick
			end
		end
	end

	def start
		super

		if Overwolf.available?
			Overwolf::Window.current.then {|w|
				if w.id.end_with?("TrackerWindow") || w.id.end_with?("TrackerClickableWindow")
					w.resize($window.screen.width, 300)
					w.move(0, 45)

					@router.navigate '/tracker'

					Overwolf::Settings.hotkey 'toggle' do
						Overwolf::Window.current.then {|i|
							if i.visible?
								i.minimize
							else
								i.restore
							end
						}
					end
					
					Overwolf::Settings.hotkey 'clickthrough' do
						Overwolf::Window.current.then {|o|
							name = w.id.end_with?('TrackerWindow') ?
								'TrackerClickableWindow' : 'TrackerWindow'

							Overwolf::Window.open(name).then {|i|
								i.restore
							}.then {
								o.close
							}
						}
					end
				else
					@router.navigate '/configuration'
				end
			}
		end
	end

	def load(component)
		element.at_css('#container').inner_dom = component.render
	end

	def storage(part)
		$window.storage(part)
	end
	expose :storage

	def world
		storage(:state)[:world] rescue nil
	end
	expose :world

	def world=(value)
		if storage(:state)[:world] != value
			storage(:state)[:world] = value

			storage(:timers).clear
			storage(:tiers).clear
			storage(:sieges).clear
		end

		value
	end
	expose :world=

	def map
		storage(:state)[:map] rescue nil
	end
	expose :map

	def map=(value)
		storage(:state)[:map] = value
	end
	expose :map=

	html do
		div.container! 'Loading...'
	end

	css! do
		rule 'html', 'body' do
			width  100.%
			height 100.%

			overflow :hidden
			user_select :none
		end
	end

	css do
		font family: 'Text',
		     size:   14.px

		style '-webkit-font-smoothing', 'subpixel-antialiased'

		color :white
		text shadow: (', 0 0 2px black' * 10)[1 .. -1] +
		             (', 0 0 1px black' * 10)
	end
end
