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
		def initialize
			@maps = {
				green:   Map.new(:green),
				blue:    Map.new(:blue),
				red:     Map.new(:red),
				eternal: Map.new(:eternal)
			}
		end

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

		on :click, '.gear' do
			Application.navigate('/config')
		end

		on :click, '.question' do
			Application.navigate('/help')
		end

		def update
			return unless id = Application.world
	
			unless @maps.any? { |_, m| m.element.class_names.include? :loaded }
				element.add_class :loading
			end

			element.at_css('.world .name').inner_text = World.name(id)
	
			Matches.find(id).then {|match|
				Promise.when World.ranks(match.region), match.details
			}.trace(2) {|match, (ranks, details)|
				element.remove_class :loading

				@maps.each {|name, component|
					unless name == :eternal
						component.name = match.__send__(name).name
						component.rank = ranks[match.__send__(name).name]
					end

					component.details = details.__send__("#{name}!")
					component.show
				}
			}
		end

		on :change, 'select' do |e|
			Application.state[:world] = e.on.value.to_i
			Application.reload

			update
		end

		on 'page:load' do
			@interval = every 60 do
				update
			end
		end

		on 'page:unload' do
			@interval.stop
		end

		on 'map:change' do |e, map|
			@maps.each_value {|m|
				m.trigger! 'map:change', map
			}
		end

		on :render do
			update
		end
	
		tag class: :selection
	
		html do |_|
			_.div.icon do
				_.img.src('img/icon.png')
			end
	
			_.div.content do
				_.div.world do
					_.div.name 'World?'
					_.div.menu do
						_.img.question
						_.img.gear
					end
					_.div.style(clear: :both)

					_ << Loader.new
	
					_.select do
						_.optgroup.label('North America') do
							World::HASH.to_a.select {|id, name|
								id.to_s[0] == ?1
							}.sort_by {|_, name|
								name
							}.each {|id, name|
								_.option.value(id) >> name
							}
						end
	
						_.optgroup.label('Europe') do
							World::HASH.to_a.select {|id, name|
								id.to_s[0] == ?2
							}.sort_by {|_, name|
								name
							}.each {|id, name|
								_.option.value(id) >> name
							}
						end
					end
				end
	
				_.div.match do
					@maps.each_value {|map|
						_ << map
					}
				end
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
				rule '.world' do
					position :relative
					margin 5.px, 0
					margin left: 35.px
	
					rule '.name' do
						pointer events: :none
					end
	
					rule '.menu' do
						vertical align: :middle

						position :absolute
						top -5.px
						right 5.px

						rule 'img' do
							cursor :pointer
							display 'inline-block'

							rule '&.gear' do
								content url('img/gear.png')
								width 23.px
								transform scale(0.9)

								position :relative
								top 3.px

								rule '&:hover' do
									content url('img/gear.active.png')
								end
							end

							rule '&.question' do
								content url('img/question.png')
								transform scale(0.9)

								position :relative
								top 1.px
								right 3.px

								rule '&:hover' do
									content url('img/question.active.png')
								end
							end
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
				end
			end

			rule '&.loading' do
				rule '.loader' do
					display :block
				end
			end

			rule '.loader' do
				display :none
				margin top: 5.px
			end
		end

		css! do
			rule 'body.small' do
				rule '.selection' do
					rule '.content' do
						rule '.world' do
							rule '.name' do
								font size: 17.px
							end
						end
					end
				end
			end

			rule 'body.normal' do
				rule '.selection' do
					rule '.content' do
						rule '.world' do
							rule '.name' do
								font size: 17.px
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
					end
				end
			end
		end
	end
end

require 'component/selection/map'
