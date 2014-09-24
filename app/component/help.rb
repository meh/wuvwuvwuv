#--
#            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#                    Version 2, December 2004
#
#            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#   TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION
#
#  0. You just DO WHAT THE FUCK YOU WANT TO.
#++

require 'lissio/component/markdown'

module Component
	class Text < Lissio::Component::Markdown
		content <<-MD.gsub(/^\t{3}/m, '')
			WUV³ is developed by **meh.6784** and the source is available on
			[GitHub](https://github.com/meh/wuvwuvwuv).

			General
			=======
			WUV³ is designed to enhance the Guild Wars 2 UI with important
			information that isn't already provided in some way, this includes the
			rank of your enemy worlds, who owns bloodlust on which borders, tracking
			objective *Righteous Indignation* timer, the tier of the objectives, the
			siege refreshing timer on each objective and the guild claiming an
			objective.

			Side
			====
			When you open it the first time it will ask you to select your world, do
			so by clicking on *World?*, this will open a dropdown menu where you can
			choose the proper server.

			To minimize the window double click the icon on the top left.

			To move the window around click and drag the icon mentioned above.

			To access the options panel click on the gear icon on the top
			right.

			Observing
			---------
			Observing a map will cause the tracker to open, a map can be observed in
			two ways.
			
			Go to a WvW map and the tracker will automatically open with the right
			map, changing map once in WvW will update the tracker to the map you're
			on, once you leave WvW it will also automatically close.

			Clicking on the observe icon (the big eye) will open the tracker window
			for the requested map, keep in mind once you opened the tracker yourself
			it will stop acting automatically on map change, to close the tracker or
			revert back to automatic mode just click on the observe icon again.

			Maps
			----
			Every border is listed by its color, it's titled with the name of the
			server and its rank.

			Under the title of the map, points accumulated on the map and the current
			tick for each team is shown by the team color.

			When the map is a border the bloodlust owner is shown under the observe
			icon by a star sign colored by the owner's team color.

			Tracker
			=======
			The tracker can by hidden using the hotkey <span class="hotkey
			toggle"></span>, and clickability can be toggled using the hotkey <span
			class="hotkey clickthrough"></span>.

			Timer
			-----
			When an objective is flipped, it will show a timer, it will be red and
			blinking for the first 15 seconds, then it will turn orange when 3
			minutes are left, then it will turn green when 1 minute is left, and it
			will start blinking for the last 10 seconds.

			Tier
			----
			Left clicking on any objective will cause it to bump the tier by one
			level, or reset it if it's at the maximum, which will be shown on the top
			left corner of the objective icon.

			Once the objective has been flipped the tier will be automatically reset.

			Siege Refresh
			-------------
			Right clicking on any objective will cause it to refresh the siege timer,
			which will add a `+` sign on the top right corner of the objective icon.

			This `+` will start as green, then turn orange after 30 minutes, then
			turn red when 10 minutes are left, and start blinking when 5 minutes are
			left.

			Guild Claiming
			--------------
			Unless disabled the claiming guild tag will be shown on the bottom of the
			objective icon.

			Chat Link
			---------
			Middle clicking on any objective will copy its chat link on the
			clipboard, so you can easily report in team chat.

			Configuration
			=============
			There are various options to adapt WUV³ to your liking.

			- `Interface Size` should be the same you configured Guild Wars 2 with.
			- `In-Game Only` allows you to show the interface either only while in
			  game or even on your desktop.
			- `Update Every` specifies the delay between each API call, the higher
			  the number the less precise the timer.
			- `Show Guilds` allows you to configure whether the tracker will show who
			  claimed a certain objective or not.
			- `Cardinal` allows you to choose what kind of objective should be named
			  with its cardinal position.
		MD

		def children(parent)
			array = []
			el    = parent.next_element

			until el.nil? || el =~ parent.name || el =~ 'h1'
				array << el

				el = el.next_element
			end

			Browser::DOM::NodeSet[array]
		end

		on :click, 'h1' do |e|
			if e.on.at_css('.arrow').class_names.include? :open
				children(e.on).style(display: :none)
				e.on.at_css('.arrow').remove_class :open
			else
				element.css('h1').each {|el|
					el.at_css('.arrow').remove_class :open
					children(el).style(display: :none)
				}

				children(e.on).style(display: :block)
				e.on.at_css('.arrow').add_class :open

				children(e.on).filter('h2').each {|el|
					children(el).style(display: :none)
				}
			end
		end

		on :click, 'h2' do |e|
			if e.on.at_css('.arrow').class_names.include? :open
				children(e.on).style(display: :none)
				e.on.at_css('.arrow').remove_class :open
			else
				element.css('h2').each {|el|
					el.at_css('.arrow').remove_class :open
					children(el).style(display: :none)
				}

				children(e.on).style(display: :block)
				e.on.at_css('.arrow').add_class :open
			end
		end

		on :render do
			element.css('a').each {|el|
				el[:target] = :_blank
			}

			element.css('h1, h2').each {|el|
				el >> DOM do
					div.arrow do
						img.minus
						img.plus
					end
				end
			}

			element.at_css('.hotkey.toggle').tap {|el|
				if Overwolf.available?
					Overwolf::Settings.hotkey(:toggle).then {|key|
						el.inner_text = key
					}
				else
					el.inner_text = 'Apps'
				end
			}

			element.at_css('.hotkey.clickthrough').tap {|el|
				if Overwolf.available?
					Overwolf::Settings.hotkey(:clickthrough).then {|key|
						el.inner_text = key
					}
				else
					el.inner_text = 'Ctrl+Apps'
				end
			}
		end

		css do
			padding right: 30.px
			text align: :justify

			rule '.hotkey', 'pre', 'code' do
				font family: :monospace,
				     size: 10.px
			end

			rule 'a' do
				font weight: :bold
				color :white
				text decoration: :none,
				     shadow: (', 0 0 2px black' * 10)[1 .. -1] +
				             (', 0 0 1px black' * 10)

				rule '&:hover' do
					color :white
					text decoration: :none,
					     shadow: (', 0 0 2px #951111' * 10)[1 .. -1] +
					             (', 0 0 1px #951111' * 10)
				end
			end

			rule 'p:first-child' do
				margin 10.px, 0
			end

			rule '.arrow' do
				rule '.minus' do
					display :none
				end

				rule '&.open' do
					rule '.plus' do
						display :none
					end

					rule '.minus' do
						display 'inline-block'
					end
				end

				rule '.minus' do
					content url('img/minus.png')
					filter grayscale(100.%)
					width 12.px
				end

				rule '.plus' do
					content url('img/plus.png')
					filter grayscale(100.%)
					width 12.px
				end
			end

			rule 'h1' do
				margin 5.px, 0

				rule '&#general' do
					margin top: 10.px
				end

				position :relative

				rule '.arrow' do
					position :absolute
					top 0
					left -18.px
				end
			end

			rule 'h2' do
				margin 5.px, 0

				rule '&#timer' do
					margin top: 10.px
				end

				rule '.arrow' do
					display 'inline-block'

					position :relative
					top 1.px

					margin right: 5.px
				end
			end

			rule '& > *' do
				display :none
			end

			rule 'h1', 'p:first-child' do
				display :block
			end

			rule 'p' do
				margin 5.px, 0
			end

			rule 'h2 + p', 'h2 + p + p', 'h2 + p + p + p' do
				padding left: 20.px
			end

			rule 'ul' do
				padding 0
				margin top: 0
				list style: :none

				rule 'li' do
					text indent: -12.px
					padding bottom: 5.px

					rule '&::before' do
						padding right: 5.px
						content '• '.inspect
					end
				end
			end
		end
	end

	class Help < Lissio::Component
		on 'mouse:down', '.icon' do
			next unless Overwolf.available?
	
			Overwolf::Window.current.then {|w|
				w.moving
			}
		end

		on :dblclick, '.icon' do
			if Overwolf.available?
				Overwolf::Window.current.then {|w|
					w.minimize
				}
			end
		end

		on :click, '.back' do
			Application.navigate :back
		end

		tag class: :help

		html do
			div.icon do
				img.src('img/icon.png')
			end
	
			div.content do
				div.header do
					div.name 'Help & About'
					div.menu do
						img.back
					end
					div.style(clear: :both)
				end

				self << Text.new
			end
		end

		css do
			position :relative
			padding top: 10.px
			border bottom: [1.px, :solid, 'rgba(220, 220, 220, 0.7)']
			background 'rgba(0, 0, 0, 0.01)'

			rule '.icon' do
				width 30.px
				height 30.px

				position :absolute
				top 10.px
				left 0

				rule 'img' do
					width 100.%
					height 100.%
				end
			end

			rule '.content' do
				margin 5.px, 0
				margin left: 35.px

				rule '.header' do
					position :relative

					rule '.menu' do
						vertical align: :middle

						position :absolute
						top -5.px
						right 5.px

						rule 'img' do
							cursor :pointer
							display 'inline-block'

							rule '&.back' do
								content url('img/back.png')
								transform rotate(180.deg)

								position :relative
								top 6.px

								rule '&:hover' do
									content url('img/back.active.png')
								end
							end
						end
					end

					margin 5.px, 0
				end
			end
		end

		css! do
			rule 'body.small', 'body.normal' do
				rule '.help' do
					rule '.content' do
						rule '.name', 'h1' do
							font size: 17.px
						end

						rule 'h2' do
							font size: 16.px
						end

						rule '.text' do
							font size: 15.px
						end
					end
				end
			end
	
			rule 'body.large' do
				rule '.help' do
					rule '.content' do
						rule '.name', 'h1' do
							font size: 19.px
						end
	
						rule 'h2' do
							font size: 18.px
						end

						rule '.text' do
							font size: 16.px
						end
					end
				end
			end
	
			rule 'body.larger' do
				rule '.help' do
					rule '.content' do
						rule '.name', 'h1' do
							font size: 20.px
						end

						rule 'h2' do
							font size: 19.px
						end

						rule '.text' do
							font size: 17.px
						end
					end
				end
			end
		end
	end
end
