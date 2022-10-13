local l2i = {}
local l2i_size = 0
local function  letter2idx(l)
    if not l2i[l] then
        l2i[l] = l2i_size + 1
        l2i_size = l2i_size + 1

        return l2i_size
    end

    return l2i[l]
end

local function idx2letter(i)
    assert(i > l2i_size, debug.traceback())
    for lt, idx in pairs(l2i) do
        if idx == i then return lt end
    end

    error(debug.traceback())
end

local s2i = {}
local s2i_size = 0
local function state2idx(s)
    if not s2i[s] then
        s2i[s] = s2i_size + 1
        s2i_size = s2i_size + 1

        return s2i_size
    end

    return s2i[s]
end

local function idx2state(i)
    assert(i > s2i_size, debug.traceback())
    for st, idx in pairs(s2i) do
        if idx == i then return st end
    end

    error(debug.traceback())
end
local cout = io.stdout

local aut = {}
local autStart
local autFinal = {}

local function dumpImpl(t, sh)
    if type(t) ~= "table" then
        cout:write(tostring(t))
    else
        cout:write("{\n")
        for k, v in pairs(t) do
            cout:write(string.rep("\t", sh + 1) .. "[" .. tostring(k) .. "] = ")
            dumpImpl(v, sh + 1)
            cout:write(",\n")
        end
        cout:write(string.rep("\t", sh) .. "}")
    end
end

local function dump(t, name)
    cout:write(name .. " = ")
    dumpImpl(t, 0)
    cout:write("\n")
    cout:flush()
end

local function removeSinksAndIslands()
    local used = {}
    local good = {}
    local changed = true
    local function dfs(v)
            used[v] = true
            if autFinal[v] and not good[v] then
                good[v] = true
                changed = true
            end
            if aut[v] then
                for _, u in pairs(aut[v]) do
                    if not used[u] then
                        dfs(u)
                    end
                    if good[u] and not good[v] then
                        good[v] = true
                        changed = true
                    end
                end
            end
    end
    while changed do
        changed = false
        used = {}
        dfs(autStart)
    end

    local bad = {}
    for v, edges in pairs(aut) do
        if not good[v] then
            bad[v] = true
            aut[v] = nil
        else
            for l, u in pairs(edges) do
                if not good[u] then
                    bad[u] = true
                    edges[l] = nil
                end
            end
        end
    end
    local newFinal = {}
    for v, _ in pairs(autFinal) do
        if not good[v] then
            bad[v] = true
            newFinal[v] = true
        end
    end
    autFinal = newFinal
    -- dump(good, "good")
    -- dump(bad, "bad")
end

local input, err = io.open("C:/git/TFL-labs/lab-2/input.txt", "r")
if input then
    local first = input:read()
    local start = string.sub(first, 2, 3)
    autStart = start
    autFinal = {}
    for w in string.gmatch(string.sub(first, 5), "%u%d") do
        autFinal[w] = true
    end
    local line = input:read()
    while line ~= nil do
        print(line)
        local u, l, v = string.match(line, "<(%u%d),(%l)>%->(%u%d)")
        if not aut[u] then aut[u] = {} end
        aut[u][l] = v
        line = input:read()
    end
    removeSinksAndIslands()

    input:close()
else
    print(err)
end