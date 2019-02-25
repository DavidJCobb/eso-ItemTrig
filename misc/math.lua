if not ItemTrig then return end

function ItemTrig.floor(v, mult)
   mult = mult or 1
	return math.floor(v / mult) * mult
end
function ItemTrig.sign(v)
	return v >= 0 and 1 or -1
end
function ItemTrig.round(v, mult)
   mult = mult or 1
	return math.floor((v / mult) + (ItemTrig.sign(v) * 0.5)) * mult
end