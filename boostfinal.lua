
boost( data.raw["recipe"]["wooden-board"] )
boost( data.raw["recipe"]["phenolic-board"] )
boost( data.raw["recipe"]["fibreglass-board"] )
boost( data.raw["recipe"]["basic-circuit-board"] )
boost( data.raw["recipe"]["electronic-circuit"] )
boost( data.raw["recipe"]["silicon-wafer"] )
boost( data.raw["recipe"]["cp-electronic-circuit-board"] )
boost( data.raw["recipe"]["rocket-engine"] )

-- uncomment to boost all recipe
-- boostall(data.raw["recipe"])

local function resetProdBonus()
  for index, force in pairs(game.forces) do
    force.reset_technology_effects()
  end
end


-- resetProdBonus()

