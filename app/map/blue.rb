#--
#            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#                    Version 2, December 2004
#
#            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#   TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION
#
#  0. You just DO WHAT THE FUCK YOU WANT TO.
#++

class Map::Blue < Map
	objectives do
		objective do
			id 59
			name 'Workshop', 'Redvale Refuge', 'Vale'
			type :camp
			location :sw
		end

		objective do
			id 25
			name 'Tower', 'Redbriar', 'Briar'
			type :tower
			location :sw
		end

		objective do
			id 27
			name 'Keep', 'Ascension Bay', 'Bay'
			type :keep
			location :w
		end

		objective do
			id 58
			name 'Quarry', 'Godslore', 'Gods'
			type :camp
			location :nw
		end

		objective do
			id 30
			name 'Tower', 'Woodhaven', 'Wood'
			type :tower
			location :nw
		end

		objective do
			id 29
			name 'Crossroads', 'The Spiritholme', 'North'
			type :camp
			location :n
		end

		objective do
			id 23
			name 'Keep', 'Garrison', 'Garri'
			type :keep
			location :c
		end

		objective do
			id 24
			name 'Orchard', "Champion's Demense", 'South'
			type :camp
			location :s
		end

		objective do
			id 28
			name 'Tower', "Dawn's Eyrie", 'Dawns'
			type :tower
			location :ne
		end

		objective do
			id 60
			name 'Lumber Mill', 'Stargrove', 'Grove'
			type :camp
			location :ne
		end

		objective do
			id 31
			name 'Keep', 'Askalion Hills', 'Hills'
			type :keep
			location :e
		end

		objective do
			id 26
			name 'Tower', 'Greenlake', 'Lake'
			type :tower
			location :se
		end

		objective do
			id 61
			name 'Fishing Village', 'Greenwater Lowlands', 'Water'
			type :camp
			location :se
		end

		separator

		objective do
			id 69
			name "Bauer's Estate"
			type :ruin
			location :nw
		end

		objective do
			id 70
			name "Battle's Hollow"
			type :ruin
			location :sw
		end

		objective do
			id 71
			name 'Temple of Lost Prayers'
			type :ruin
			location :s
		end

		objective do
			id 67
			name "Carver's Ascent"
			type :ruin
			location :se
		end

		objective do
			id 68
			name 'Orchard Overlook'
			type :ruin
			location :ne
		end
	end
end
