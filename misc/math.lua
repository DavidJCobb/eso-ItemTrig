if not ItemTrig then return end

function ItemTrig.sign(v)
	return v >= 0 and 1 or -1
end
function ItemTrig.round(v)
	return math.floor(v + ItemTrig.sign(v) * 0.5)
end