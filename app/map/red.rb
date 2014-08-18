#--
#            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#                    Version 2, December 2004
#
#            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#   TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION
#
#  0. You just DO WHAT THE FUCK YOU WANT TO.
#++

class Map::Red < Map
	objectives do
		objective do
			id 53
			name 'Workshop', 'Greenvale Refuge', 'Vale'
			type :camp
			location :sw
		end

		objective do
			id 35
			name 'Tower', 'Greenbriar', 'Briar'
			type :tower
			location :sw
		end

		objective do
			id 33
			name 'Keep', 'Dreaming Bay', 'Bay'
			type :keep
			location :w
		end

		objective do
			id 52
			name 'Quarry', "Arah's Hope", 'Arah'
			type :camp
			location :nw
		end

		objective do
			id 38
			name 'Tower', 'Longview'
			type :tower
			location :nw
		end

		objective do
			id 39
			name 'Crossroads', 'The Godsword', 'North'
			type :camp
			location :n
		end

		objective do
			id 37
			name 'Keep', 'Garrison', 'Garri'
			type :keep
			location :c
		end

		objective do
			id 34
			name 'Orchard', "Victor's Lodge", 'South'
			type :camp
			location :s
		end

		objective do
			id 40
			name 'Tower', 'Cliffside', 'Cliff'
			type :tower
			location :ne
		end

		objective do
			id 51
			name 'Lumber Mill', 'Astralholme', 'Astral'
			type :camp
			location :ne
		end

		objective do
			id 32
			name 'Keep', 'Etheron Hills', 'Hills'
			type :keep
			location :e
		end

		objective do
			id 36
			name 'Tower', 'Bluelake', 'Lake'
			type :tower
			location :se
		end

		objective do
			id 50
			name 'Fishing Village', 'Bluewater Lowlands', 'Water'
			type :camp
			location :se
		end
		
		separator

		objective do
			id 64
			name "Bauer's Estate"
			type :ruin
			location :nw
		end

		objective do
			id 63
			name "Battle's Hollow"
			type :ruin
			location :sw
		end

		objective do
			id 62
			name 'Temple of Lost Prayers'
			type :ruin
			location :s
		end

		objective do
			id 66
			name "Carver's Ascent"
			type :ruin
			location :se
		end

		objective do
			id 65
			name 'Orchard Overlook'
			type :ruin
			location :ne
		end
	end
end
