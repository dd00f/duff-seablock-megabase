
-- set to true to enable info logs
local infoEnabled = false

-- set to true to enable debug logs
local debugEnabled = false

function debugLog (message)
	if( debugEnabled ) then
		log ( message )
	end
end

function infoLog (message)
	if( infoEnabled ) then
		log ( message )
	end
end

function boostRecipe (a, name)
  debugLog ("boosting ".. name)
  
  if( not a.energy_required ) then 
    debugLog ("injecting missing energy_required for ".. name .." at 0.5")
	a.energy_required = 0.5
  end
  
  if( a.energy_required < 2 ) then 
	local boostfactor = 3 / a.energy_required
	infoLog ("boosting ".. name .." with boost factor ".. boostfactor)
    debugLog(serpent.block(a))
	
	a.energy_required = 3
	
	if( a.result_count ) then
		a.result_count = a.result_count * boostfactor
		debugLog (name .. " boosting a.result_count to ".. a.result_count)
	elseif( a.results ) then 
		for i,v in pairs(a.results) do 
			if( v.amount ) then 
				v.amount = v.amount * boostfactor
				debugLog (name .. " " .. i .. " result boosting v.amount to ".. v.amount)
			elseif( v.amount_min ) then
				v.amount_min = v.amount_min * boostfactor
				if( v.amount_max ) then
					v.amount_max = v.amount_max * boostfactor
				end
			else
				v[2] = v[2] * boostfactor
				debugLog("boosted ingredient array " .. v[1] .. " to " .. v[2])
			end 
		end
	else
		a.result_count = boostfactor
		debugLog (name .. " injecting missing boosting a.result_count to ".. a.result_count)
	end

	if( a.ingredients ) then 
		for i,v in pairs(a.ingredients) do 
			if( v.amount ) then 
				v.amount = v.amount * boostfactor
				debugLog (name .. " " .. i .." ingredients boosting v.amount to " ..v.amount)
			else
				v[2] = v[2] * boostfactor
				debugLog("boosted ingredient array " .. v[1] .. " to " .. v[2])
			end 
		end
	end
  end
end




function boost (a)

  if( a ) then 

	  if( a.normal ) then
		boostRecipe( a.normal, a.name.." normal" )
	  else
		boostRecipe( a, a.name )
	  end 
	  
	  if( a.expensive ) then
		boostRecipe( a.expensive, a.name.." expensive" )
	  end  
  end
end


function boostall (a)
	for i,v in pairs(a) do 
		boost(v)
	end
end


