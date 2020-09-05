print('TEST VERSION')

local component = require 'component'
local event = require 'event'

local charts = require 'charts'

--[[
    currently supports (at least) the following:
    thermal expansion
    enderio
    ic2
    refined storage
    mekanism
]]--

-- [[ SETTINGS ]] --

local FG_COLOR = 0xFFFFFF
local BG_COLOR = 0x000000
local LOOP_DELAY = .35

-- [[ END SETTINGS ]] --

-- combine tables, appending array section
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

-- calculate number of elements in a table
local function tSize(t)
    local c = 0
    for _ in pairs(t) do
        c = c + 1
    end
    return c
end

-- build a proxied list of cell components
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

local function buildContainer(gpu)
    local w, h = gpu.getResolution()
    return charts.Container({
        x = 0,
        y = 0,
        gpu = gpu,
        fg = FG_COLOR,
        bg = BG_COLOR,
        width = w,
        height = h,
    })
end

local function buildHistogram(cells)
    -- TODO maybe actually do some configuring in here?
    local histogram = charts.Histogram()
    histogram.sources = cells
    return histogram
end

local function updateHistogram(histogram, lim)
    local max, cur = 0, 0
    local values = histogram.values
    for _,src in ipairs(histogram.sources) do
        local t = src.type
        if t == 'energy_device' or t == 'basic_energy_cube' then
            max = max + src.getMaxEnergyStored()
            cur = cur + src.getEnergyStored()
        elseif t:match('^ic2_te_[a-z_]') then -- ic2 devices
            max = max + src.getCapacity()
            cur = cur + src.getEnergy()
        end
    end
    values[#values + 1] = cur / max
    if #values > lim then
        table.remove(values, 1)
    end
    histogram.values = values
    return histogram
end

local function loop(container)
    container.payload = updateHistogram(container.payload, container.width)
    container:draw()
end


local function main()
    print('initializing...')
    local gpu = component.gpu
    print('getting list of cells...')
    local cells = getCells()
    print('found '..tostring(tSize(cells))..' cells')
    print('building container...')
    local container = buildContainer(gpu)
    print('building histogram...')
    container.payload = buildHistogram(cells)
    print('starting main loop...')
    while true do
        loop(container)
        local _,_,k = event.pull(LOOP_DELAY, 'key_down')
        if k == 113 then -- if q is pressed
            break        -- then leave the loop
        end
    end
end

main()
