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
			To choose your world just click on *World?* and select the right one from
			the dropdown menu.

			Every borderland item includes the rank of the world, the scores made by
			each world in that map and the owner of bloodlust.

			To open the tracker click on the scout icon for the map you want to
			track; left-clicking one of the objective icons will increase the tier
			tracker, right-clicking will reset the siege refresh tracker.

			WUV³ is developed by **meh.6784** and the source is available on
			[GitHub](https://github.com/meh/wuvwuvwuv).
		MD

		on :render do
			element.css('a').each {|el|
				el[:target] = :_blank
			}
		end

		css do
			padding right: 30.px
			text align: :justify

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
		end
	end

	class Help < Lissio::Component
		on 'mouse:down' do
			next unless Overwolf.available?
	
			Overwolf::Window.current.then {|w|
				w.moving
			}
		end
	
		on :click, '.fa-arrow-circle-left' do
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
						i.fa.fa[:arrow, :circle, :left]
					end
					div.style(clear: :both)
				end

				self << Text.new
			end
		end

		css do
			position :relative
			padding 10.px, 0
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
					rule '.name' do
						float :left
					end

					rule '.menu' do
						vertical align: :middle
						float :right
						margin right: 10.px

						rule 'i' do
							cursor :pointer
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
						rule '.name' do
							font size: 18.px
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
						rule '.name' do
							font size: 19.px
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
						rule '.name' do
							font size: 20.px
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
