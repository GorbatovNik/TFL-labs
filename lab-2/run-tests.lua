require("lab-2")

local CFG_NUMBER_OF_TESTS = 2
local CFG_TESTNAME_FORMAT = "test-%d"

for i = 1, CFG_NUMBER_OF_TESTS do
    Solve(string.format(CFG_TESTNAME_FORMAT, i))
end