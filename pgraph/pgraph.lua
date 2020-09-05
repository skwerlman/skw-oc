print('TEST VERSION')

local component = require 'component'

local charts = require 'charts'

--[[
    currently supports (at least) the following:
    thermal expansion
    enderio
    ic2
    refined storage
    mekanism
]]--

-- join lists of cells
local function joinLists(lists)
    local joined = {}
    for _,list in ipairs(lists) do
        for k,v in pairs(list) do
            if type(k) == 'number' then
                table.insert(joined, v)
            else
                joined[k] = v
            end
        end
    end
    return joined
end

local function tSize(t)
    local c = 0
    for _ in pairs(t) do
        c = c + 1
    end
    return c
end

local function getCells()
    local cells = joinLists({
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
    local proxiedCells = {}
    for addr in pairs(cells) do
        table.insert(proxiedCells, component.proxy(addr))
    end
    return proxiedCells
end

local function main()
    print('initializing...')
    local gpu = component.gpu
    print('getting list of cells...')
    local cells = getCells()
    print('found '..tostring(tSize(cells))..' cells')
end

main()
