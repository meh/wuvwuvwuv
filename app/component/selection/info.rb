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
		def initialize(details)
			@details = details
			@map     = Map.const_get(details.name.capitalize).new
		end

		def score_for(color)
			@details.select {|objective|
				objective.owner == color
			}.map {|objective|
				@map[objective.id].points
			}.reduce(0, :+)
		end

		html do |_|
			if bonus = @details.bonuses.find { |b| b.type == :bloodlust }
				_.span.bloodlust.__send__(bonus.owner) do
					'✻'
				end
			else
				_.span.none '✻'
			end

			_.div.green do
				_.span.score @details.scores!.green
				_.span.tick "+#{score_for(:green)}"
			end

			_.div.red do
				_.span.score @details.scores!.red
				_.span.tick "+#{score_for(:red)}"
			end

			_.div.blue do
				_.span.score @details.scores!.blue
				_.span.tick "+#{score_for(:blue)}"
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

			rule '.bloodlust' do
				margin right: 1.5.ch
			end

			rule '.none' do
				opacity 0
				margin right: 1.ch
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
	end
end
