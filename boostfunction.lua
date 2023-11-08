
-- set to true to enable info logs
local infoEnabled = false

-- set to true to enable debug logs
local debugEnabled = false

local MINIMUM_ENERGY_REQUIRED = 2

local NO_BOOST_APPLIED = -1

local DEFAULT_ENERGY_REQUIRED = 0.5

local BOOST_TARGET_TIME = 3

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

function calculateBoost (energy, targetTime)
	return targetTime / energy
end

function isItemNameStackable(itemName)

	resultItem = data.raw["fluid"][itemName]
	if( resultItem == nil ) then
		resultItem = data.raw["item"][itemName]
	end

	if( resultItem == nil ) then
		-- not an item, skipping
		debugLog ("Not an ItemPrototype, deemed not stackable : " .. itemName)
		return false
	end
		
	if( resultItem.flags ~= nil ) then 
		for j,w in ipairs(resultItem.flags) do 
			if( w == "not-stackable" ) then 
				if(debugEnabled) then
					debugLog ("Item with flag not-stackable=true found :\n" .. serpent.block(resultItem))
				end
				return false
			end 
		end 
	end 
	return true
end

-- a = data structure of the recipe to boost, could be the root, normal or expensive data structure
-- name = name of the recipe to boost
-- rootBoostFactor = boost factor applied to the root of normal or expensive recipes. -1 if none was set
function boostRecipe (a, name, rootBoostFactor, targetTime, minimumTime)

	targetTime = targetTime or BOOST_TARGET_TIME
	minimumTime = minimumTime or MINIMUM_ENERGY_REQUIRED

	debugLog ("boost check on  ".. name .." with root boost factor ".. rootBoostFactor)

	local boostFactor = 1
	if( rootBoostFactor ~= NO_BOOST_APPLIED ) then
		boostFactor = rootBoostFactor
	end

	if( a.energy_required and a.energy_required >= minimumTime ) then 
		debugLog ("Recipe " .. name .. " energy required of " .. a.energy_required ..  " already matches minimum of " ..  minimumTime )
		return NO_BOOST_APPLIED
	end
	
	if( a.result ) then
		if( not isItemNameStackable(a.result) ) then 
			debugLog ("Skipped applying boost to recipe " .. name .. " because it has item " .. a.result .. " that is not-stackable")
			return NO_BOOST_APPLIED
		end
	elseif( a.results ) then
		for i,v in pairs(a.results) do 
			if( not isItemNameStackable(v.name) ) then 
				debugLog ("Skipped applying boost to recipe " .. name .. " because it has item " .. v.name .. " that is not-stackable")
				return NO_BOOST_APPLIED
			end
		end
	end


	-- both parent & current recipe didn't explicitly define a energy_required, setting the default of DEFAULT_ENERGY_REQUIRED
	if( rootBoostFactor == NO_BOOST_APPLIED ) then
		if( not a.energy_required ) then 
			debugLog ("injecting missing energy_required for ".. name .." at " .. DEFAULT_ENERGY_REQUIRED)
			a.energy_required = DEFAULT_ENERGY_REQUIRED
		end
	end
	
	if( a.energy_required ) then 
		boostFactor = calculateBoost( a.energy_required, targetTime )
	end

	if( boostFactor ==  1 ) then
		infoLog ("Recipe " .. name .. " boostFactor is 1, no boost required")
		return NO_BOOST_APPLIED
	end
	
	infoLog ("boosting ".. name .." with boost factor ".. boostFactor)
	
	if( a.energy_required ) then
		a.energy_required = a.energy_required * boostFactor
		debugLog (name .. " boosting a.energy_required to ".. a.energy_required)
	end

	if( a.result_count ) then
		a.result_count = a.result_count * boostFactor
		debugLog (name .. " boosting a.result_count to ".. a.result_count)
	elseif( a.results ) then 
		for i,v in pairs(a.results) do 
			if( v.amount ) then 
				v.amount = v.amount * boostFactor
				debugLog (name .. " " .. i .. " result boosting v.amount to ".. v.amount)
			elseif( v.amount_min ) then
				v.amount_min = v.amount_min * boostFactor
				if( v.amount_max ) then
					v.amount_max = v.amount_max * boostFactor
				end
			else
				v[2] = v[2] * boostFactor
				debugLog("boosted ingredient array " .. v[1] .. " to " .. v[2])
			end 
		end
	else
		a.result_count = boostFactor
		debugLog (name .. " injecting missing boosting a.result_count to ".. a.result_count)
	end

	if( a.ingredients ) then 
		for i,v in pairs(a.ingredients) do 
			if( v.amount ) then 
				v.amount = v.amount * boostFactor
				debugLog (name .. " " .. i .." ingredients boosting v.amount to " ..v.amount)
			else
				v[2] = v[2] * boostFactor
				debugLog("boosted ingredient array " .. v[1] .. " to " .. v[2])
			end 
		end
	end
	
	return boostFactor
end


function boost (a, targetTime, minimumTime)

	if( a ) then 

		debugLog ("before boost :\n" .. serpent.block(a))

		local boostFactor = NO_BOOST_APPLIED

		if( a.energy_required ) then 
			boostFactor = boostRecipe( a, a.name, boostFactor, targetTime, minimumTime )
		end

		if( a.normal ) then
			boostRecipe( a.normal, a.name.." normal", boostFactor, targetTime, minimumTime )
		elseif ( not a.energy_required ) then
			boostRecipe( a, a.name, boostFactor, targetTime, minimumTime )
		end 

		if( a.expensive ) then
			boostRecipe( a.expensive, a.name.." expensive", boostFactor, targetTime, minimumTime )
		end  

		if( debugEnabled ) then
			debugLog ("after boost :\n" .. serpent.block(a))
		end

	end
end


function boostall (a)
	for i,v in pairs(a) do 
		boost(v)
	end
end


function boostPattern (a, targetTime, minimumTime)
  	debugLog ("pattern match " .. a .. " start")
	for i,v in pairs(data.raw["recipe"]) do 
		if( string.match( i, a ) ) then
			debugLog ("pattern match " .. a .. " matched " .. i .. ", BOOSTING")
			boost(v, targetTime, minimumTime)
		end
	end  
  	debugLog ("pattern match " .. a .. " end")
end


