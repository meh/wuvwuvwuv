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
	class Configuration < Lissio::Component
		on 'mouse:down' do
			next unless Overwolf.available?
	
			Overwolf::Window.current.then {|w|
				w.moving
			}
		end
	
		on :click, '.fa-arrow-circle-left' do
			Application.size     = element.at_css('.size td:nth-child(2) select').value
			Application.interval = element.at_css('.interval td:nth-child(2) input').value.to_i

			Application.navigate :back
		end

		on :change, '.size td:nth-child(2) select' do
			update
		end

		on :render do
			element.at_css(".size td:nth-child(2) select option[value='#{Application.size}']")[:selected] = :selected
			element.at_css('.interval td:nth-child(2) input').value = Application.interval

			update
		end

		def update
			element.at_css('.size td:nth-child(2) .value').inner_text =
				element.at_css('.size td:nth-child(2) select').value.capitalize
		end

		tag class: :configuration

		html do
			div.icon do
				img.src('img/icon.png')
			end
	
			div.content do
				div.header do
					div.name 'Configuration'
					div.menu do
						i.fa.fa[:arrow, :circle, :left]
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

					tr.interval do
						td 'Update Every :'
						td do
							input.type(:text).max(1)
							span ' seconds'
						end
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

				rule 'table' do
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
				end
			end
		end

		css! do
			rule 'body.small', 'body.normal' do
				rule '.configuration' do
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
				rule '.configuration' do
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
				rule '.configuration' do
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
