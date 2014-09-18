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
	class Loader < Lissio::Component
		tag class: :loader

		html do
			span 'Loading'

			div.ellipsis do
				div.one   '.'
				div.two   '.'
				div.three '.'
			end
		end

		css do
			rule '.ellipsis' do
				display 'inline-block'

				rule '& > div' do
					display 'inline-block'
					opacity 0
					animation :ellipsis, 0.6.s, :infinite
				end

				rule '.one' do
					animation! delay: 0.s
				end

				rule '.two' do
					animation! delay: 0.2.s
				end

				rule '.three' do
					animation! delay: 0.4.s
				end
			end

			animation :ellipsis do
				step 0.% do
					opacity 0
				end

				step 50.% do
					opacity 0
				end

				step 100.% do
					opacity 1
				end
			end
		end
	end
end
