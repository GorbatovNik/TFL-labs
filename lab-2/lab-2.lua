-- local l2i = {}
-- local l2i_size = 0
-- local function  letter2idx(l)
--     if not l2i[l] then
--         l2i[l] = l2i_size + 1
--         l2i_size = l2i_size + 1

--         return l2i_size
--     end

--     return l2i[l]
-- end

-- local function idx2letter(i)
--     assert(i > l2i_size, debug.traceback())
--     for lt, idx in pairs(l2i) do
--         if idx == i then return lt end
--     end

--     error(debug.traceback())
-- end

-- local s2i = {}
-- local s2i_size = 0
-- local function state2idx(s)
--     if not s2i[s] then
--         s2i[s] = s2i_size + 1
--         s2i_size = s2i_size + 1

--         return s2i_size
--     end

--     return s2i[s]
-- end

-- local function idx2state(i)
--     assert(i > s2i_size, debug.traceback())
--     for st, idx in pairs(s2i) do
--         if idx == i then return st end
--     end

--     error(debug.traceback())
-- end
local cout = io.stdout

local aut = {}
local autStart
local autFinal = {}
local classes = {}
local letters = {}
local bor = {}
local srs = {}

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
    dump(good, "good")
    dump(bad, "bad")
end

local function compose(transp1, transp2)
    local res = {}
    for v, u in pairs(transp1) do
        if transp2[u] then
            res[v] = transp2[u]
        end
    end
    return res
end

local function includes(class1, class2)
    for v, u in pairs(class1) do
        if u ~= class2[v] then return false end
    end

    return true
end

local function equal(class1, class2)
    return includes(class1, class2) and includes(class2, class1)
end

local function belong(cl, cls)
    for word, trans in pairs(cls) do
        if equal(trans, cl) then return word end
    end
    return
end

local function borCheck(word)
    local br = bor
    for i = 1, string.len(word) do
        local l = string.sub(word, i, i)
        if not br[l] then return false end
        br = br[l]
    end
    return true
end

local function borAdd(word)
    local br = bor
    local ln = string.len(word)
    for i = 1, ln - 1 do
        br = br[string.sub(word, i, i)]
    end
    br[string.sub(word, ln, ln)] = {}
end

List = {}
function List.new()
    return {first = 0, last = -1}
end
function List.pushright(list, value)
    local last = list.last + 1
    list.last = last
    list[last] = value
    end
function List.popleft(list)
    local first = list.first
    if first > list.last then error("list is empty") end
    local value = list[first]
    list[first] = nil
    list.first = first + 1
    return value
end
function List.empty(list)
    return list.last < list.first
end

function Solve(testName)
    dump(testName, "testName")
    local input, err = io.open(testName .. ".txt", "r")
    if input then
        local output = io.open(testName .. "-out.txt", "w+")
        local first = input:read()
        print(first)
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

        local words = List.new()

        for v, edges in pairs(aut) do
            for l, u in pairs(edges) do
                if not classes[l] then
                    classes[l] = {}
                    table.insert(letters, l)
                    bor[l] = {}
                    List.pushright(words, l)
                end
                classes[l][v] = u
            end
        end
        -- dump(classes, "classes")
        -- dump(letters, "letters")

        -- dump(words, "words")
        while not List.empty(words) do
            local word = List.popleft(words)
            for _, l in ipairs(letters) do
                local newWord = word .. l
                if borCheck(string.sub(newWord, 2)) then
                    local newTransp = compose(classes[word], classes[l])
                    local className = belong(newTransp, classes)
                    if className then
                        srs[newWord] = className
                    else
                        dump(newTransp, "new class " .. newWord)
                        classes[newWord] = newTransp
                        borAdd(newWord)
                        List.pushright(words, newWord)
                    end
                end
            end
        end

        dump(srs, "srs")

        for w, transp in pairs(classes) do
            output:write(string.format("%s := { ", w))
            for v, u in pairs(transp) do
                output:write(string.format("(%s,%s), ", v, u))
            end
            output:write("}\n")
        end

        for s1, s2 in pairs(srs) do
            output:write(string.format("%s->%s\n", s1, s2))
        end
        input:close()
        output:flush()
        output:close()
        aut = {}
        autStart = nil
        autFinal = {}
        classes = {}
        letters = {}
        bor = {}
        srs = {}
    else
        print(err)
    end
end