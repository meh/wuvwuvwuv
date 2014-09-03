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
	class Objective < Lissio::Component
		def initialize(objective)
			@objective = objective
		end

		def method_missing(*args, &block)
			@objective.__send__(*args, &block)
		end

		def update
			reload

			icon = element.at_css(".icon img")
			icon.remove_class :red, :green, :blue

			unless owner == :neutral
				icon.add_class owner
			end

			claim = element.at_css('.icon .guild')

			if guild
				claim.inner_text = "[#{guild.tag}]"
			else
				claim.inner_text = ''
			end

			unless ruin?
				tier  = element.at_css(".icon .tier")
				siege = element.at_css(".icon .siege")
				timer = element.at_css(".timer")

				tier.inner_text  = ''
				siege.inner_text = ''
				timer.inner_text = '4:55'
				timer.add_class :active
			end
		end

		def timer
			next unless el = element.at_css('.timer.active')

			minutes, seconds = el.inner_text.split(':').map(&:to_i)

			if minutes == 0 && seconds == 1
				el.inner_text = ''
				el.remove_class :active, :lowest

				next
			end

			if seconds == 0
				el.inner_text = "%d:59" % (minutes - 1)
			else
				el.inner_text = "%d:%02d" % [minutes, seconds - 1]
			end

			if minutes == 4 && seconds == 55
				el.add_class :highest
			elsif minutes == 4 && seconds == 45
				el.remove_class :highest
				el.add_class :high
			elsif minutes == 3 && seconds == 0
				el.remove_class :high
				el.add_class :medium
			elsif minutes == 1 && seconds == 0
				el.remove_class :medium
				el.add_class :low
			elsif minutes == 0 && seconds == 10
				el.remove_class :low
				el.add_class :lowest
			end
		end

		def siege
			el   = element.at_css('.siege')
			diff = Time.new.to_i - refreshed

			if diff > 60 * 60
				el.inner_text = ''
			elsif diff > 55 * 60
				el.inner_text = '+'
				el.remove_class :low, :medium, :high
				el.add_class :highest
			elsif diff > 50 * 60
				el.inner_text = '+'
				el.remove_class :low, :medium, :highest
				el.add_class :high
			elsif diff > 30 * 60
				el.inner_text = '+'
				el.remove_class :low, :high, :highest
				el.add_class :medium
			else
				el.inner_text = '+'
				el.remove_class :medium, :high, :highest
				el.add_class :low
			end
		end

		on :click, '.icon img' do |e|
			next if ruin?

			el = element.at_css('.icon .tier')

			if tier == 3 || (tier == 2 && camp?)
				self.tier = 0
				el.inner_text = ''
			else
				self.tier += 1
				el.inner_text = tier
			end

			save
		end

		on 'context:menu', '.icon img' do |e|
			self.refreshed = Time.new.to_i
			save

			siege
		end

		on :render do
			epoch      = Time.new.to_i
			difference = epoch - capped

			if difference > 0 && difference <= 5 * 60
				el        = element.at_css(".timer")
				remaining = (5 * 60) - difference
				minutes   = (remaining / 60).floor
				seconds   = remaining % 60

				el.inner_text = '%d:%02d' % [minutes, seconds]
				el.add_class :active

				if minutes == 4 && seconds > 45
					el.add_class :highest
				elsif minutes >= 3
					el.add_class :high
				elsif minutes >= 1
					el.add_class :medium
				elsif seconds > 10
					el.add_class :low
				else
					el.add_class :lowest
				end
			end

			if owner != :neutral
				element.at_css(".icon img").add_class owner
			end

			if guild
				element.at_css('.icon .guild').inner_text = "[#{guild.tag}]"
			end

			if tier > 0
				element.at_css('.icon .tier').inner_text = tier
			end

			every 1 do
				timer
			end

			every 60 do
				siege
			end

			siege

			$window.on :storage do |e|
				next e.off unless element.parent
				next unless e.key == "#{map.name}.#{id}"

				update
			end
		end

		tag class: :objective

		html do |_|
			_.div.icon do
				_.div.siege
				_.div.tier
				_.div.guild
				_.img(class: type).data(name: name)
			end

			_.div.name do
				if ruin? || Application.state["cardinal.#{type}"]
					_.div.cardinal cardinal.upcase
				else
					_.div name
				end
			end

			_.div.timer
		end

		css do
			text align: :center
			vertical align: :top
			display 'inline-block'
			padding bottom: 10.px

			rule '.timer' do
				padding top: 5.px
			end

			rule '.icon' do
				position :relative

				rule '.tier' do
					position :absolute
					right 6.px
					font size: 14.px
				end

				rule '.siege' do
					position :absolute
					left 6.px
					font size: 14.px
				end

				rule '.guild' do
					width 100.%
					position :absolute
					left 0
					bottom 4.px
					font size: 8.px

					pointer events: :none
				end

				rule 'img' do
					height 28.px
					width  28.px

					rule '&.ruin' do
						height 24.px
						width  24.px

						padding top: 3.px,
						        bottom: 2.px
					end

					rule '&.camp' do
						content 'url(img/camp.png)'

						%w[red blue green].each do |color|
							rule "&.#{color}" do
								content "url(img/camp.#{color}.png)"
							end
						end
					end

					rule '&.tower' do
						content 'url(img/tower.png)'

						%w[red blue green].each do |color|
							rule "&.#{color}" do
								content "url(img/tower.#{color}.png)"
							end
						end
					end

					rule '&.keep' do
						content 'url(img/keep.png)'

						%w[red blue green].each do |color|
							rule "&.#{color}" do
								content "url(img/keep.#{color}.png)"
							end
						end
					end

					rule '&.castle' do
						content 'url(img/castle.png)'

						%w[red blue green].each do |color|
							rule "&.#{color}" do
								content "url(img/castle.#{color}.png)"
							end
						end
					end

					rule '&.ruin' do
						{ "Carver's Ascent"        => 'carvers_ascent',
							'Orchard Overlook'       => 'orchard_overlook',
							"Bauer's Estate"         => 'bauers_estate',
							"Battle's Hollow"        => 'battles_hollow',
							'Temple of Lost Prayers' => 'temple_of_lost_prayers'
						}.each {|name, path|
							rule %Q{&[data-name="#{name}"]} do
								content "url(img/#{path}.png)"

								%w[red blue green].each do |color|
									rule "&.#{color}" do
										content "url(img/#{path}.#{color}.png)"
									end
								end
							end
						}
					end
				end
			end

			rule '.highest' do
				text shadow: (', 0 0 2px #b20000' * 10)[1 .. -1] +
				             (', 0 0 1px #b20000' * 10)

				animation 'blink 1s linear infinite'
			end

			rule '.high' do
				text shadow: (', 0 0 2px #b20000' * 10)[1 .. -1] +
				             (', 0 0 1px #b20000' * 10)
			end

			rule '.medium' do
				text shadow: (', 0 0 2px #ff6000' * 10)[1 .. -1] +
				             (', 0 0 1px #ff6000' * 10)
			end

			rule '.low' do
				text shadow: (', 0 0 2px #007a20' * 10)[1 .. -1] +
				             (', 0 0 1px #007a20' * 10)
			end

			rule '.lowest' do
				text shadow: (', 0 0 2px #007a20' * 10)[1 .. -1] +
				             (', 0 0 1px #007a20' * 10)

				animation 'blink 1s linear infinite'
			end
		end

		css! do
			rule 'body.small', 'body.normal' do
				rule '.objective' do
					font size: 14.px
					width 40.px
				end
			end

			rule 'body.large' do
				rule '.objective' do
					font size: 15.px
					width 44.px
				end
			end

			rule 'body.larger' do
				rule '.objective' do
					font size: 16.px
					width 46.px
				end
			end

			media '(max-width: 1024px)' do
				# RIP ;_;
			end

			media '(max-width: 1280px)' do
				rule 'body.small', 'body.normal' do
					rule '.tracker.eternal' do
						rule '.objective' do
							font size: 10.px
							width 34.px

							rule '.timer' do
								font size: 14.px
							end
						end
					end
				end
			end

			media '(max-width: 1366px)' do
				rule 'body.small', 'body.normal' do
					rule '.tracker.eternal' do
						rule '.objective' do
							font size: 10.px
							width 34.px

							rule '.timer' do
								font size: 14.px
							end
						end
					end
				end
			end

			media '(max-width: 1440px)' do
				rule 'body.small', 'body.normal' do
					rule '.tracker.eternal' do
						rule '.objective' do
							font size: 10.px
							width 38.px

							rule '.timer' do
								font size: 14.px
							end
						end
					end
				end

				rule 'body.large' do
					rule '.tracker.eternal' do
						rule '.objective' do
							font size: 10.px
							width 36.px

							rule '.timer' do
								font size: 14.px
							end
						end
					end
				end
			end

			media '(max-width: 1680px)' do
				rule 'body.small', 'body.normal' do
					rule '.tracker.eternal' do
						rule '.objective' do
							font size: 13.px
							width 48.px

							rule '.timer' do
								font size: 14.px
							end
						end
					end
				end

				rule 'body.large' do
					rule '.tracker.eternal' do
						rule '.objective' do
							font size: 12.px
							width 46.px

							rule '.timer' do
								font size: 15.px
							end
						end
					end
				end

				rule 'body.larger' do
					rule '.tracker.eternal' do
						rule '.objective' do
							font size: 12.px
							width 43.px

							rule '.timer' do
								font size: 16.px
							end
						end
					end
				end
			end

			media '(max-width: 1920px)' do
				rule 'body.small', 'body.normal' do
					rule '.tracker.eternal' do
						rule '.objective' do
							font size: 14.px
							width 50.px

							rule '.timer' do
								font size: 14.px
							end
						end
					end
				end

				rule 'body.large' do
					rule '.tracker.eternal' do
						rule '.objective' do
							font size: 15.px
							width 56.px

							rule '.timer' do
								font size: 15.px
							end
						end
					end
				end

				rule 'body.larger' do
					rule '.tracker.eternal' do
						rule '.objective' do
							font size: 15.px
							width 54.px

							rule '.timer' do
								font size: 16.px
							end
						end
					end
				end
			end
		end
	end
end
