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
require 'browser/immediate'
require 'browser/console'

require 'world'
require 'match'
require 'map'
require 'updater'
require 'mumble'

require 'component/mumble'
require 'component/selection'
require 'component/help'
require 'component/configuration'
require 'component/tracker'

class Application < Lissio::Application
	def initialize(*)
		super

		router.fragment!

		route '/select' do
			load Component::Selection.new
			resize!
		end

		route '/help' do
			load Component::Help.new
			resize!
		end

		route '/config' do
			load Component::Configuration.new
			resize!
		end

		route '/tracker' do
			load Component::Tracker.new(map)
			move!
		end

		@mumble = Component::Mumble.new
	end

	def start
		super

		if Overwolf.available?
			Overwolf::Game.on :change do |u|
				next if show?

				if u.focus?
					next unless u.game.title == "Guild Wars 2"

					Overwolf::Window.current.then {|w|
						if u.game.focus?
							w.restore if @visible
						else
							w.minimize
							@visible = w.visible?
						end
					}
				end
			end

			Overwolf::Window.current.then {|w|
				if w.id.end_with?("TrackerWindow") || w.id.end_with?("TrackerClickableWindow")
					w.resize($window.screen.width, 300)

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

					@router.navigate '/tracker'
					setup(:tracker)
				else
					@router.navigate '/select'
					setup(:selection)
				end
			}
		else
			if @router.path == '/select'
				setup(:selection)
			elsif @router.path == '/tracker'
				setup(:tracker)
			end
		end
	end

	def setup(what)
		if what == :selection
			state.delete(:map)
			state.delete('map.explicit')

			updater
		elsif what == :tracker
			$window.on :storage do |e|
				refresh if e.key == :reload
			end
		end
	end

	def reload
		$window.storage(:reload)[:value] = !$window.storage(:reload)[:value]
	end
	expose :reload

	def load(component)
		@current.trigger! 'page:unload' if @current
		@current = component

		element.at_css('#container').inner_dom = @current.render

		@current.trigger! 'page:load'
	end

	def updater
		@updater ||= Updater.new(world, interval)
	end

	def mumble?
		@mumble.available?
	end
	expose :mumble?

	def mumble
		@mumble.new
	end
	expose :mumble

	def state
		$window.storage(:state)
	end
	expose :state

	def show?
		state[:show]
	end
	expose :show?

	def no_guilds?
		state[:no_guilds]
	end
	expose :no_guilds?

	def cardinal?(type)
		state["cardinal.#{type}"]
	end
	expose :cardinal?

	def world
		state[:world]
	end
	expose :world

	def map
		state[:map]
	end
	expose :map

	def map!(value)
		state[:map]           = value
		state['map.explicit'] = !value.nil?

		if Overwolf.available?
			Promise.when(Overwolf::Window.open('TrackerWindow'),
			             Overwolf::Window.open('TrackerClickableWindow')).then {|u, c|
				window = c.closed? ? u : c

				if value.nil?
					window.close
				elsif window.closed?
					window.restore
				else
					reload
				end
			}
		else
			reload
		end

		@current.trigger! :map, value if @current
	end
	expose :map!

	def map=(value)
		next if state['map.explicit']

		state[:map] = value

		if Overwolf.available?
			Promise.when(Overwolf::Window.open('TrackerWindow'),
			             Overwolf::Window.open('TrackerClickableWindow')).then {|u, c|
				window = c.closed? ? u : c

				if value.nil?
					window.close
				elsif window.closed?
					window.restore
				else
					reload
				end
			}
		else
			reload
		end

		@current.trigger! :map, value if @current
	end
	expose :map=

	def size
		state[:size] || :normal
	end
	expose :size

	def size=(value)
		state[:size] = value
		element.remove_class(:small, :normal, :large, :larger)
		element.add_class(value)

		resize!
	end
	expose :size=

	def interval
		state[:interval] || 2
	end
	expose :interval

	def interval=(value)
		state[:interval] = value
		updater.interval = value
	end
	expose :interval=

	def move!
		y = case size
				when :small  then 41
				when :normal then 45
				when :large  then 50
				when :larger then 55
				end

		if Overwolf.available?
			Overwolf::Window.current.then {|w|
				w.move(0, y)
			}
		end
	end

	def resize!
		width = case size
						when :small  then 260
						when :normal then 300
						when :large  then 320
						when :larger then 360
						end

		if Overwolf.available?
			Overwolf::Window.current.then {|w|
				w.resize(width, 400)
			}
		else
			element.at_css('#container').style \
				margin: 20.px,
			  border: '2px solid black',
			  width: width.px,
			  height: 400.px
		end
	end

	on :render do
		element.add_class(size)
	end

	html do |_|
		_ << @mumble
		_.div.container! 'Loading...'
	end

	css! do
		rule 'html', 'body' do
			width 100.%
			height 100.%

			overflow :hidden
			user_select :none
		end

		animation :blink do
			step 0.% do
				opacity 1
			end

			step 50.% do
				opacity 0
			end

			step 100.% do
				opacity 1
			end
		end

		rule '.blink' do
			animation :blink, 1.s, :linear, :infinite
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
