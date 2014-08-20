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
	on 'mouse:down' do
		next unless Overwolf.available?

		Overwolf::Window.current.then {|w|
			w.moving
		}
	end

	on :click, '.icon' do
		if Overwolf.available?
			Overwolf::Window.current.then {|w|
				w.minimize
			}
		end
	end

	on :click, '.match img' do |e|
		next unless Application.world

		Application.map = e.on.parent.class_name

		if Overwolf.available?
			Promise.when(Overwolf::Window.open('TrackerWindow'),
				           Overwolf::Window.open('TrackerClickableWindow')).then {|u, c|
				name   = c.visible? ? 'TrackerClickableWindow' : 'TrackerWindow'
				window = c.visible? ? c : u

				if window.visible?
					window.close

					Overwolf::Window.open(name).then {|w|
						w.restore
					}
				else
					window.restore
				end
			}
		end
	end

	class Info < Lissio::Component
		def initialize(map)
			@map = map
		end

		html do |_|
			_.span.green @map.scores.green
			_.span.red   @map.scores.red
			_.span.blue  @map.scores.blue

			if bonus = @map.bonuses.find { |b| b.type == :bloodlust }
				_.span.bloodlust.__send__(bonus.owner) do
					'✻'
				end
			end
		end

		css do
			rule '.green' do
				text shadow: (', 0 0 2px #017d3f' * 10)[1 .. -1] +
				             (', 0 0 1px #017d3f' * 10)
			end

			rule '.red' do
				text shadow: (', 0 0 2px #951111' * 10)[1 .. -1] +
				             (', 0 0 1px #951111' * 10)
			end

			rule '.blue' do
				text shadow: (', 0 0 2px #006b99' * 10)[1 .. -1] +
				             (', 0 0 1px #006b99' * 10)
			end

			rule 'span' do
				margin right: 10.px

				rule '&.blue' do
					margin right: 8.px
				end
			end
		end
	end

	def update
		id = Application.world

		element.at_css('.world .name').inner_text = Match::WORLDS[id]

		Match.find(id).then {|m|
			element.at_css('.match .green .name').inner_text = m.green.name
			element.at_css('.match .red .name').inner_text = m.red.name
			element.at_css('.match .blue .name').inner_text = m.blue.name

			Rank.fetch(m.region).then {|ranks|
				element.at_css('.match .green .rank').inner_text = ranks[m.green.name]
				element.at_css('.match .red .rank').inner_text = ranks[m.red.name]
				element.at_css('.match .blue .rank').inner_text = ranks[m.blue.name]
			}

			m.details.then {|d|
				element.at_css('.match .green .info').inner_dom = Info.new(d.green).render
				element.at_css('.match .red .info').inner_dom = Info.new(d.red).render
				element.at_css('.match .blue .info').inner_dom = Info.new(d.blue).render
				element.at_css('.match .eternal .info').inner_dom = Info.new(d.eternal).render
			}.rescue {|e|
				$window.alert e.inspect
			}
		}
	end

	on :render do
		if Application.world
			update
		end

		every 15 * 60 do
			update
		end
	end

	on :change, 'select' do |e|
		Application.world = e.on.value.to_i
		update
	end

	html do
		div.icon do
			img.src('img/icon.png')
		end

		div.content do
			div.world do
				div.name 'World?'

				select do
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
			end

			div.match do
				div.green do
					img.src('img/scout.png')
					span.name 'Green Borderlands'
					span.rank

					div.info
				end

				div.red do
					img.src('img/scout.png')
					span.name 'Red Borderlands'
					span.rank

					div.info
				end

				div.blue do
					img.src('img/scout.png')
					span.name 'Blue Borderlands'
					span.rank

					div.info
				end

				div.eternal do
					img.src('img/scout.png')
					span.name 'Eternal Battlegrounds'

					div.info
				end
			end
		end
	end

	css do
		position :relative
		padding 10.px, 0
		border bottom: [1.px, :solid, 'rgba(220, 220, 220, 0.85)']
		background 'rgba(0, 0, 0, 0.01)'

		width 300.px
		height 195.px

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
			position :absolute
			top 10.px
			right 0

			width 265.px
			height 300.px

			rule '.world' do
				position :relative
				margin 5.px, 0

				rule '.name' do
					position :absolute
					top 0
					left 0

					width 100.%
					pointer events: :none

					font size: 18.px
				end

				rule 'select' do
					opacity 0
					border :none
					background :white

					height 25.px

					rule '&:focus' do
						outline :none
					end
				end
			end

			rule '.match' do
				position :relative

				rule '& > div' do
					margin bottom: 5.px
				end

				rule 'img' do
					display 'inline-block'
					vertical align: :middle
					cursor :pointer
				end

				rule '.name' do
					font size: 16.px
					margin left: 5.px
					position :relative
					top 2.px
				end

				rule '.rank' do
					margin left: 5.px
				end

				rule '.info' do
					margin left: 25.px
				end

				rule '.green' do
					rule '.name' do
						text shadow: (', 0 0 2px #017d3f' * 10)[1 .. -1] +
						             (', 0 0 1px #017d3f' * 10)
					end
				end

				rule '.red' do
					rule '.name' do
						text shadow: (', 0 0 2px #951111' * 10)[1 .. -1] +
						             (', 0 0 1px #951111' * 10)
					end
				end

				rule '.blue' do
					rule '.name' do
						text shadow: (', 0 0 2px #006b99' * 10)[1 .. -1] +
						             (', 0 0 1px #006b99' * 10)
					end
				end
			end
		end
	end
end
