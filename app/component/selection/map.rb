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
	class Selection::Map < Lissio::Component
		def initialize(name)
			@name = name
			@map  = ::Map.const_get(name.capitalize).new
		end

		def show
			element.add_class :loaded
		end

		def rank(n)
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

		def name=(value)
			element.at_css('.name').inner_text = value
			element.at_css('.rest').inner_text = 'Borderlands'
		end

		def rank=(value)
			element.at_css('.rank').inner_text = rank(value)
		end

		def details=(details)
			%w[green red blue].each {|color|
				element.at_css(".info .#{color} .score").inner_text =
					details.scores!.__send__(color)

				tick = details.select {|objective|
					objective.owner == color
				}.map {|objective|
					@map[objective.id].points
				}.reduce(0, :+)

				element.at_css(".info .#{color} .tick").inner_text = "+#{tick}"
			}

			unless @name == :eternal
				bloodlust = element.at_css('.info > span')

				if bonus = details.bonuses.find { |b| b.type == :bloodlust }
					bloodlust.add_class :bloodlust, @name
					bloodlust.remove_class :none
				else
					bloodlust.add_class :none
					bloodlust.remove_class :bloodlust, @name
				end
			end
		end

		on :click, '.observe' do |e|
			next unless Application.world
	
			if e.on.class_names.include? :active
				Application.map! nil
			else
				Application.map! @name
			end
		end

		on 'map:change' do |e, map|
			element.css('.observe').remove_class(:active)

			if @name == map
				element.at_css('.observe').add_class :active
			end
		end

		on :render do
			element.add_class @name

			if @name == :eternal
				element.at_css('.name').inner_text = 'Eternal Battlegrounds'
			end

			if @name == Application.map
				element.at_css('.observe').add_class :active
			end
		end

		html do
			img.observe
			span.name
			span.rank
			span.rest

			div.info do
				span.none '✻'

				div.green do
					span.score
					span.tick
				end

				div.red do
					span.score
					span.tick
				end

				div.blue do
					span.score
					span.tick
				end
			end
		end

		css do
			margin bottom: 10.px

			display :none

			rule '&.loaded' do
				display :block
			end

			rule 'img' do
				content url('img/observe.png')
				display 'inline-block'
				vertical align: :middle
				cursor :pointer
				margin right: 4.px
				width 20.px

				rule '&.active' do
					content url('img/observe.active.png')
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
				margin left: 4.px
				padding top: 2.px

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

				rule '.bloodlust' do
					margin right: 11.px
					font size: 13.px
				end
	
				rule '.none' do
					opacity 0
					margin right: 12.px
					font size: 13.px
				end

				rule '& > div' do
					display 'inline-block'
					margin right: 2.ch
	
					rule 'span.tick' do
						margin left: 1.ch
					end
	
					rule '&:last-child' do
						margin 0
					end
				end
			end

			rule '&.green' do
				rule '.name', '.rest' do
					text shadow: (', 0 0 2px #017d3f' * 10)[1 .. -1] +
					             (', 0 0 1px #017d3f' * 10)
				end
			end

			rule '&.red' do
				rule '.name', '.rest' do
					text shadow: (', 0 0 2px #951111' * 10)[1 .. -1] +
					             (', 0 0 1px #951111' * 10)
				end
			end

			rule '&.blue' do
				rule '.name', '.rest' do
					text shadow: (', 0 0 2px #006b99' * 10)[1 .. -1] +
					             (', 0 0 1px #006b99' * 10)
				end
			end
		end

		css! do
			rule 'body.small' do
				rule '.selection' do
					rule '.content' do
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

			rule 'body.normal' do
				rule '.selection' do
					rule '.content' do
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
