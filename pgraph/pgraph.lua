print('TEST VERSION')

local component = require 'component'

local charts = require 'charts'

-- currently supports (at least) the following:
--[[
    thermal expansion
    enderio
    ic2
    refined storage
    mekanism
]]--

-- join lists of cells
local function joinLists(lists) do
    local joined = {}
    for _,list in ipairs(lists) do
        for _,item in ipairs(list) do
            table.insert(joined, item)
        end
    end
    return joined
end

local function getCells() do
    return joinLists({
        -- rf-based cells (te, eio, rs)
        component.list('energy_device'),

        -- mekanism cells
        -- (yes all the cubes appear as 'basic')
        component.list('basic_energy_cube'),

        --ic2 cells
        component.list('ic2_te_batbox'),
        component.list('ic2_te_cesu'),
        component.list('ic2_te_mfe'),
        component.list('ic2_te_mfsu'),
        component.list('ic2_te_chargepad_batbox'),
        component.list('ic2_te_chargepad_cesu'),
        component.list('ic2_te_chargepad_mfe'),
        component.list('ic2_te_chargepad_mfsu'),
    })
end

local function main() do
    print('initializing...')
    local gpu = component.gpu
    print('getting list of cells...')
    local cells = getCells()
    print('found '..tostring(string.len(cells))..' cells')
end

main()
