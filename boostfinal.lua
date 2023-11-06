
--boost( data.raw["recipe"]["wooden-board"] )
--boost( data.raw["recipe"]["phenolic-board"] )
--boost( data.raw["recipe"]["fibreglass-board"] )
--boost( data.raw["recipe"]["basic-circuit-board"] )
--boost( data.raw["recipe"]["electronic-circuit"] )
--boost( data.raw["recipe"]["silicon-wafer"] )
--boost( data.raw["recipe"]["cp-electronic-circuit-board"] )
--boost( data.raw["recipe"]["rocket-engine"] )
--boost( data.raw["recipe"]["angels-glass-fiber-board"] )
--boost( data.raw["recipe"]["solid-rubber"] )
--
--
--boostPattern('angelsore.-processing');

-- Make void recipes longer to reduce the UPS cost of dynamically selecting void recipes
boostPattern('-void-', 60, 40);

-- Make the flare stack fluid capacity bigger to support the larger voiding recipe above
flareStack = data.raw["furnace"]["angels-flare-stack"]
if flareStack then
	-- 100 x 100 = 10,000 fluid
	flareStack.fluid_boxes[1].base_area = 100
end

-- Make the clarifier fluid capacity bigger to support the larger voiding recipe above
clarifier = data.raw["furnace"]["clarifier"]
if clarifier then
	-- 100 x 100 = 10,000 fluid
	clarifier.fluid_boxes[1].base_area = 100
end

-- uncomment to boost all recipe
boostall(data.raw["recipe"])

local function resetProdBonus()
  for index, force in pairs(game.forces) do
    force.reset_technology_effects()
  end
end


-- resetProdBonus()

