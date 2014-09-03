#--
#            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#                    Version 2, December 2004
#
#            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#   TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION
#
#  0. You just DO WHAT THE FUCK YOU WANT TO.
#++

module Component
	class Selection < Lissio::Component
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

		on :click, '.fa-gear' do
			Application.navigate('/config')
		end

		on :click, '.fa-question-circle' do
			Application.navigate('/help')
		end
	
		on :click, '.match img' do |e|
			next unless Application.world
	
			Application.map! e.on.parent.class_name
		end

		def rank_for(n)
			if n == 1
				'1st'
			elsif n == 2 || n == 22
				"#{n}nd"
			elsif n == 3 || n == 23
				"#{n}rd"
			else
				"#{n}th"
			end
		end
	
		def update
			id = Application.world
	
			element.at_css('.world .name').inner_text = World.name(id)
	
			Matches.find(id).then {|m|
				element.at_css('.match .green .name').inner_text = m.green.name
				element.at_css('.match .red .name').inner_text = m.red.name
				element.at_css('.match .blue .name').inner_text = m.blue.name

				World.ranks(m.region).then {|ranks|
					element.at_css('.match .green .rank').inner_text = rank_for(ranks[m.green.name])
					element.at_css('.match .red .rank').inner_text = rank_for(ranks[m.red.name])
					element.at_css('.match .blue .rank').inner_text = rank_for(ranks[m.blue.name])
				}
	
				m.details.then {|d|
					element.at_css('.match .green .info').inner_dom = Info.new(d.green!).render
					element.at_css('.match .red .info').inner_dom = Info.new(d.red!).render
					element.at_css('.match .blue .info').inner_dom = Info.new(d.blue!).render
					element.at_css('.match .eternal .info').inner_dom = Info.new(d.eternal!).render
				}
			}
		end

		on :change, 'select' do |e|
			Application.state[:world] = e.on.value.to_i
			Application.reload

			update
		end

		on :map do |e, map|
			element.css('.match img').remove_class(:active)

			if map
				element.at_css(".match .#{map} img").add_class :active
			end
		end

		on :render do
			if Application.world
				update
			end

			if map = Application.map
				element.at_css(".match .#{map} img").add_class :active
			end
	
			every 60 do
				update
			end
		end
	
		tag class: :selection
	
		html do
			div.icon do
				img.src('img/icon.png')
			end
	
			div.content do
				div.world do
					div.name 'World?'
					div.menu do
						i.fa.fa[:question, :circle]
						i.fa.fa[:gear]
					end
					div.style(clear: :both)
	
					select do
						optgroup.label('North America') do
							World::HASH.to_a.select {|id, name|
								id.to_s[0] == ?1
							}.sort_by {|_, name|
								name
							}.each {|id, name|
								option.value(id) >> name
							}
						end
	
						optgroup.label('Europe') do
							World::HASH.to_a.select {|id, name|
								id.to_s[0] == ?2
							}.sort_by {|_, name|
								name
							}.each {|id, name|
								option.value(id) >> name
							}
						end
					end
				end
	
				div.match do
					div.green do
						img.src('img/scout.png')
						span.name 'Green'
						span.rank
						span.rest 'Borderlands'
	
						div.info
					end
	
					div.red do
						img.src('img/scout.png')
						span.name 'Red'
						span.rank
						span.rest 'Borderlands'
	
						div.info
					end
	
					div.blue do
						img.src('img/scout.png')
						span.name 'Blue'
						span.rank
						span.rest 'Borderlands'
	
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
				rule '.world' do
					position :relative
					margin 5.px, 0
					margin left: 35.px
	
					rule '.name' do
						float :left
						pointer events: :none
					end
	
					rule '.menu' do
						vertical align: :middle
	
						float :right
						margin right: 10.px
	
						rule 'i' do
							cursor :pointer
							padding left: 7.px
						end
					end
	
					rule 'select' do
						opacity 0
						border :none
						background :white
	
						height 25.px
	
						position :absolute
						top 0
						left 0
	
						rule '&:focus' do
							outline :none
						end
					end
				end
	
				rule '.match' do
					position :relative
					margin top: 5.px, left: 8.px
	
					rule '& > div' do
						margin bottom: 10.px
					end
	
					rule 'img' do
						display 'inline-block'
						vertical align: :middle
						cursor :pointer
						margin right: 4.px

						opacity 0.8

						rule '&.active' do
							opacity 1
						end
					end
	
					rule '.name' do
						margin left: 3.px
						position :relative
						top 2.px
					end
	
					rule '.rank' do
						margin left: 5.px
						position :relative
						top -3.px
						left -3.px
					end
	
					rule '.rest' do
						padding left: 2.px
						position :relative
						top 2.px
					end
	
					rule '.info' do
						margin left: 7.px
						padding top: 2.px
					end
	
					rule '.green' do
						rule '.name', '.rest' do
							text shadow: (', 0 0 2px #017d3f' * 10)[1 .. -1] +
							             (', 0 0 1px #017d3f' * 10)
						end
					end
	
					rule '.red' do
						rule '.name', '.rest' do
							text shadow: (', 0 0 2px #951111' * 10)[1 .. -1] +
							             (', 0 0 1px #951111' * 10)
						end
					end
	
					rule '.blue' do
						rule '.name', '.rest' do
							text shadow: (', 0 0 2px #006b99' * 10)[1 .. -1] +
							             (', 0 0 1px #006b99' * 10)
						end
					end
				end
			end
		end

		css! do
			rule 'body.small', 'body.normal' do
				rule '.selection' do
					rule '.content' do
						rule '.world' do
							rule '.name' do
								font size: 18.px
							end
						end
	
						rule '.match' do
							font size: 15.px
	
							rule '.rank' do
								font size: 12.px
							end
	
							rule '.info' do
								font size: 14.px
							end
	
							rule '.bloodlust' do
								font size: 13.px
							end
						end
					end
				end
			end
	
			rule 'body.large' do
				rule '.selection' do
					rule '.content' do
						rule '.world' do
							rule '.name' do
								font size: 19.px
							end
						end
	
						rule '.match' do
							font size: 16.px
	
							rule '.rank' do
								font size: 13.px
							end
	
							rule '.info' do
								font size: 15.px
							end
	
							rule '.bloodlust' do
								font size: 14.px
							end
						end
					end
				end
			end
	
			rule 'body.larger' do
				rule '.selection' do
					rule '.content' do
						rule '.world' do
							rule '.name' do
								font size: 20.px
							end
						end
	
						rule '.match' do
							font size: 17.px
	
							rule '.rank' do
								font size: 14.px
							end
	
							rule '.info' do
								font size: 16.px
							end
	
							rule '.bloodlust' do
								font size: 15.px
							end
						end
					end
				end
			end
		end
	end
end

require 'component/selection/info'
