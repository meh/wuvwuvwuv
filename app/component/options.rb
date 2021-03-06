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
	class Options < Lissio::Component
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
			Application.size     = element.at_css('.size td:nth-child(2) select').value
			Application.interval = element.at_css('.interval td:nth-child(2) input').value.to_i

			element.css('.cardinal span').each {|el|
				type   = el.class_names - [:active]
				active = el.class_names.include? :active

				Application.state["cardinal.#{type}"] = active
			}

			Application.state[:no_guilds] = element.at_css('.guilds span').inner_text == 'No'
			Application.state[:show]      = element.at_css('.show span').inner_text == 'No'

			Application.reload
			Application.navigate :back
		end

		on :change, '.size td:nth-child(2) select' do
			update
		end

		on :click, '.show span, .guilds span' do |e|
			if e.on.inner_text == 'Yes'
				e.on.inner_text = 'No'
			else
				e.on.inner_text = 'Yes'
			end
		end

		on :click, '.cardinal span' do |e|
			if e.on.class_names.include? :active
				e.on.remove_class :active
			else
				e.on.add_class :active
			end
		end

		on :render do
			element.at_css(".size td:nth-child(2) select option[value='#{Application.size}']")[:selected] = :selected
			element.at_css('.show span').inner_text = Application.show? ? 'No' : 'Yes'
			element.at_css('.interval td:nth-child(2) input').value = Application.interval

			element.css('.cardinal span').each {|el|
				type = el.class_names - [:active]

				if Application.state["cardinal.#{type}"]
					el.add_class :active
				end
			}

			element.at_css('.guilds span').inner_text = Application.no_guilds? ? 'No' : 'Yes'

			update
		end

		def update
			element.at_css('.size td:nth-child(2) .value').inner_text =
				element.at_css('.size td:nth-child(2) select').value.capitalize
		end

		tag class: :options

		html do
			div.icon do
				img.src('img/icon.png')
			end
	
			div.content do
				div.header do
					div.name 'Options'
					div.menu do
						img.back
					end
					div.style(clear: :both)
				end

				table do
					tr.size do
						td 'Interface Size :'
						td do
							div.value 'Normal'

							select do
								option.value(:small)  >> 'Small'
								option.value(:normal) >> 'Normal'
								option.value(:large)  >> 'Large'
								option.value(:larger) >> 'Larger'
							end
						end
					end

					tr.show do
						td 'In-Game Only :'
						td do
							span
						end
					end

					tr.interval do
						td 'Update Every :'
						td do
							input.type(:text).max(1)
							span ' seconds'
						end
					end

					tr.guilds do
						td 'Show Guilds :'
						td do
							span
						end
					end

					tr.cardinal do
						td 'Cardinal :'
						td do
							span.keep  'Keep'
							span.tower 'Tower'
							span.camp  'Camp'
						end
					end
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

				rule 'table' do
					rule 'tr' do
						rule 'td' do
							position :relative
							white space: :nowrap

							rule '&:first-child' do
								padding right: 7.px
							end

							rule 'select' do
								position :absolute
								top 0
								left 0
								opacity 0
							end

							rule 'input' do
								background :transparent
								border 0
								display 'inline-block'
								width 1.ch

								color :white
								text shadow: (', 0 0 2px black' * 10)[1 .. -1] +
							             	 (', 0 0 1px black' * 10)

								rule '&:focus' do
									outline :none
								end
							end
						end

						rule '&.cardinal' do
							rule 'span' do
								padding right: 1.ch

								rule '&.active' do
									text shadow: (', 0 0 2px #007a20' * 10)[1 .. -1] +
									             (', 0 0 1px #007a20' * 10)
								end
							end
						end
					end
				end
			end
		end

		css! do
			rule 'body.small', 'body.normal' do
				rule '.options' do
					rule '.content' do
						rule '.name' do
							font size: 18.px
						end

						rule 'table' do
							font size: 15.px
						end
					end
				end
			end
	
			rule 'body.large' do
				rule '.options' do
					rule '.content' do
						rule '.name' do
							font size: 19.px
						end
	
						rule 'table' do
							font size: 16.px
						end
					end
				end
			end
	
			rule 'body.larger' do
				rule '.options' do
					rule '.content' do
						rule '.name' do
							font size: 20.px
						end
	
						rule 'table' do
							font size: 17.px
						end
					end
				end
			end
		end
	end
end
