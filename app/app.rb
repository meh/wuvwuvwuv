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

			Match.find(world).then {|m|
				updater = -> {
					m.details.then {|d|
						@map.update(d)

						updater.after(5)
					}
				}

				updater.()
			}.rescue {|e|
				$console.log e
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
				if w.id.end_with? "TrackerWindow"
					w.resize($window.screen.width, 300)
					w.move(0, 45)

					@router.navigate '/tracker'

					Overwolf::Settings.hotkey 'toggle' do
						Overwolf::Window.current.then {|w|
							if w.visible?
								w.minimize
							else
								w.restore
							end
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

	def world
		$window.storage(:wvw)[:world] rescue nil
	end
	expose :world

	def world=(value)
		$window.storage(:wvw)[:world] = value
	end
	expose :world=

	def map
		$window.storage(:wvw)[:map] rescue nil
	end
	expose :map

	def map=(value)
		$window.storage(:wvw)[:map] = value
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
		style 'text-shadow',
			(', 0 0 2px black' * 10)[1 .. -1] +
			(', 0 0 1px black' * 10)
	end
end
