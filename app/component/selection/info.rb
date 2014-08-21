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
	class Selection::Info < Lissio::Component
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
end
