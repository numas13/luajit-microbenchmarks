local format, lower, sub = string.format, string.lower, string.sub
local write = io.write

local default_path = "baseline.csv"

local list_benchmarks = false
local n = 1e4
local repeats = 10
local load_baseline = nil
local save_baseline = nil
local freq = nil
local filter = {}

local function print_usage()
    print("Usage: micro FREQ [FILTER]")
    print()
    print("Available positional items:")
    print("    FREQ                     CPU frequency in GHz")
    print("    FILTER                   REGEX strings to filter microbenchmarks")
    print()
    print("Available options:")
    print("    -l                       List available benchmarks")
    print("    -i N                     Set iteration count to N")
    print("    -r N                     Set repeat count to N")
    print("    -b                       Load baseline from "..default_path)
    print("    -B PATH                  Load baseline from PATH")
    print("    -s                       Save baseline to "..default_path)
    print("    -S PATH                  Save baseline to PATH")
end

local fail, skip = false, false
for i,v in ipairs(arg) do
    if skip then
        skip = false
    elseif v == "-h" then
        print_usage()
        return
    elseif v == "-l" then
        list_benchmarks = true
    elseif v == "-i" then
        n = tonumber(arg[i + 1])
        if not n then
            io.stderr:write("invalid -n\n")
            return 1
        end
        skip = true
    elseif v == "-r" then
        repeats = tonumber(arg[i + 1])
        if not repeats then
            io.stderr:write("invalid -r\n")
            return 1
        end
        skip = true
    elseif v == "-b" then
        load_baseline = default_path
    elseif v == "-B" then
        load_baseline = arg[i + 1]
        if not load_baseline then
            io.stderr:write("expect PATH for -B\n")
            return 1
        end
        skip = true
    elseif v == "-s" then
        save_baseline = default_path
    elseif v == "-S" then
        save_baseline = arg[i + 1]
        if not save_baseline then
            io.stderr:write("expect PATH for -S\n")
            return 1
        end
        skip = true
    elseif freq == nil then
        freq = v
    else
        if sub(v, 1, 1) == "-" then
            io.stderr:write(format("unexpected %s\n", v))
            fail = true
        else
            filter[#filter+1] = v
        end
    end
end

if fail then
    return 1
end

if freq == nil then
    print_usage()
    return
end

freq = tonumber(freq)
if freq == nil then
    print("invalid frequency")
    return 1
end

for i,f in ipairs(filter) do
    filter[i] = lower(f)
end

local benches = {}

local function bench(name, desc, func)
    for i,j in ipairs(benches) do
        assert(not (j.name == name and j.desc == desc),
                "bench \""..name.."\" \""..desc.."\" already exists")
    end
    benches[#benches+1] = { name = name, desc = desc, func = func }
end

local function bench_func(name, f, note, ...)
    local args_count = select("#", ...)
    local desc = name.."("
    local args = {}
    for i = 1,args_count do
        local v = select(i, ...)
        args[i] = v
        if i > 1 then
            desc = desc..", "
        end
        local t = type(v)
        if t == "number" then
            desc = desc..format("%.1f", v)
        elseif t == "string" then
            desc = desc.."\""..v.."\""
        elseif t == "boolean" or t == "nil" then
            desc = desc..tostring(t)
        else
            desc = desc.."#"..t
        end
    end
    desc = desc..")"
    if note then
        desc = desc.." -- "..note
    end
    if args_count == 0 then
        bench(name, desc, function(n)
            local f = f
            local tm = os.clock()
            for i = 1,n do
                f(); f(); f(); f(); f();
                f(); f(); f(); f(); f();
                f(); f(); f(); f(); f();
                f(); f(); f(); f(); f();
            end
            return os.clock() - tm, 20
        end)
    elseif args_count == 1 then
        bench(name, desc, function(n)
            local f, x = f, args[1]
            local tm = os.clock()
            for i = 1,n do
                f(x); f(x); f(x); f(x); f(x);
                f(x); f(x); f(x); f(x); f(x);
                f(x); f(x); f(x); f(x); f(x);
                f(x); f(x); f(x); f(x); f(x);
            end
            return os.clock() - tm, 20
        end)
    elseif args_count == 2 then
        bench(name, desc, function(n)
            local f, x, y = f, args[1], args[2]
            local tm = os.clock()
            for i = 1,n do
                f(x, y); f(x, y); f(x, y); f(x, y); f(x, y);
                f(x, y); f(x, y); f(x, y); f(x, y); f(x, y);
                f(x, y); f(x, y); f(x, y); f(x, y); f(x, y);
                f(x, y); f(x, y); f(x, y); f(x, y); f(x, y);
            end
            return os.clock() - tm, 20
        end)
    elseif args_count == 3 then
        bench(name, desc, function(n)
            local f, x, y, z = f, args[1], args[2], args[3]
            local tm = os.clock()
            for i = 1,n do
                f(x, y, z); f(x, y, z); f(x, y, z); f(x, y, z); f(x, y, z);
                f(x, y, z); f(x, y, z); f(x, y, z); f(x, y, z); f(x, y, z);
                f(x, y, z); f(x, y, z); f(x, y, z); f(x, y, z); f(x, y, z);
                f(x, y, z); f(x, y, z); f(x, y, z); f(x, y, z); f(x, y, z);
            end
            return os.clock() - tm, 20
        end)
    elseif args_count == 4 then
        bench(name, desc, function(n)
            local f, x, y, z, w = f, args[1], args[2], args[3], args[4]
            local tm = os.clock()
            for i = 1,n do
                f(x, y, z, w); f(x, y, z, w); f(x, y, z, w); f(x, y, z, w); f(x, y, z, w);
                f(x, y, z, w); f(x, y, z, w); f(x, y, z, w); f(x, y, z, w); f(x, y, z, w);
                f(x, y, z, w); f(x, y, z, w); f(x, y, z, w); f(x, y, z, w); f(x, y, z, w);
                f(x, y, z, w); f(x, y, z, w); f(x, y, z, w); f(x, y, z, w); f(x, y, z, w);
            end
            return os.clock() - tm, 20
        end)
    else
        print("TODO: function with "..args_count.." arguments")
    end
end

local function bench_func_0(name, f, note)
    bench_func(name, f, note)
end

local function bench_func_1(name, f, x, note)
    bench_func(name, f, note, x)
end

local function bench_func_2(name, f, x, y, note)
    bench_func(name, f, note, x, y)
end

local function bench_func_3(name, f, x, y, z, note)
    bench_func(name, f, note, x, y, z)
end

local function bench_func_4(name, f, x, y, z, w, note)
    bench_func(name, f, note, x, y, z, w)
end

------------------------------------------------------------------------------
-- ISGT
------------------------------------------------------------------------------

bench("ISGT", "taken", function(n)
    local x, y = 0, 1
    local tm = os.clock()
    for i = 1,n do
        if x >= y then end; if x >= y then end; if x >= y then end; if x >= y then end; if x >= y then end;
        if x >= y then end; if x >= y then end; if x >= y then end; if x >= y then end; if x >= y then end;
        if x >= y then end; if x >= y then end; if x >= y then end; if x >= y then end; if x >= y then end;
        if x >= y then end; if x >= y then end; if x >= y then end; if x >= y then end; if x >= y then end;
    end
    return os.clock() - tm, 20
end)

bench("ISGT", "not taken", function(n)
    local x, y = 2, 1
    local tm = os.clock()
    for i = 1,n do
        if x >= y then end; if x >= y then end; if x >= y then end; if x >= y then end; if x >= y then end;
        if x >= y then end; if x >= y then end; if x >= y then end; if x >= y then end; if x >= y then end;
        if x >= y then end; if x >= y then end; if x >= y then end; if x >= y then end; if x >= y then end;
        if x >= y then end; if x >= y then end; if x >= y then end; if x >= y then end; if x >= y then end;
    end
    return os.clock() - tm, 20
end)

------------------------------------------------------------------------------
-- ISGE
------------------------------------------------------------------------------

bench("ISGE", "taken", function(n)
    local x, y = 0, 1
    local tm = os.clock()
    for i = 1,n do
        if x > y then end; if x > y then end; if x > y then end; if x > y then end; if x > y then end;
        if x > y then end; if x > y then end; if x > y then end; if x > y then end; if x > y then end;
        if x > y then end; if x > y then end; if x > y then end; if x > y then end; if x > y then end;
        if x > y then end; if x > y then end; if x > y then end; if x > y then end; if x > y then end;
    end
    return os.clock() - tm, 20
end)

bench("ISGE", "not taken", function(n)
    local x, y = 2, 1
    local tm = os.clock()
    for i = 1,n do
        if x > y then end; if x > y then end; if x > y then end; if x > y then end; if x > y then end;
        if x > y then end; if x > y then end; if x > y then end; if x > y then end; if x > y then end;
        if x > y then end; if x > y then end; if x > y then end; if x > y then end; if x > y then end;
        if x > y then end; if x > y then end; if x > y then end; if x > y then end; if x > y then end;
    end
    return os.clock() - tm, 20
end)

------------------------------------------------------------------------------
-- ISLT
------------------------------------------------------------------------------

bench("ISLT", "taken", function(n)
    local x, y = 0, 1
    local tm = os.clock()
    for i = 1,n do
        if not (x < y) then end; if not (x < y) then end; if not (x < y) then end; if not (x < y) then end; if not (x < y) then end;
        if not (x < y) then end; if not (x < y) then end; if not (x < y) then end; if not (x < y) then end; if not (x < y) then end;
        if not (x < y) then end; if not (x < y) then end; if not (x < y) then end; if not (x < y) then end; if not (x < y) then end;
        if not (x < y) then end; if not (x < y) then end; if not (x < y) then end; if not (x < y) then end; if not (x < y) then end;
    end
    return os.clock() - tm, 20
end)

bench("ISLT", "not taken", function(n)
    local x, y = 2, 1
    local tm = os.clock()
    for i = 1,n do
        if not (x < y) then end; if not (x < y) then end; if not (x < y) then end; if not (x < y) then end; if not (x < y) then end;
        if not (x < y) then end; if not (x < y) then end; if not (x < y) then end; if not (x < y) then end; if not (x < y) then end;
        if not (x < y) then end; if not (x < y) then end; if not (x < y) then end; if not (x < y) then end; if not (x < y) then end;
        if not (x < y) then end; if not (x < y) then end; if not (x < y) then end; if not (x < y) then end; if not (x < y) then end;
    end
    return os.clock() - tm, 20
end)

------------------------------------------------------------------------------
-- ISLE
------------------------------------------------------------------------------

bench("ISLE", "taken", function(n)
    local x, y = 0, 1
    local tm = os.clock()
    for i = 1,n do
        if not (x <= y) then end; if not (x <= y) then end; if not (x <= y) then end; if not (x <= y) then end; if not (x <= y) then end;
        if not (x <= y) then end; if not (x <= y) then end; if not (x <= y) then end; if not (x <= y) then end; if not (x <= y) then end;
        if not (x <= y) then end; if not (x <= y) then end; if not (x <= y) then end; if not (x <= y) then end; if not (x <= y) then end;
        if not (x <= y) then end; if not (x <= y) then end; if not (x <= y) then end; if not (x <= y) then end; if not (x <= y) then end;
    end
    return os.clock() - tm, 20
end)

bench("ISLE", "not taken", function(n)
    local x, y = 2, 1
    local tm = os.clock()
    for i = 1,n do
        if not (x <= y) then end; if not (x <= y) then end; if not (x <= y) then end; if not (x <= y) then end; if not (x <= y) then end;
        if not (x <= y) then end; if not (x <= y) then end; if not (x <= y) then end; if not (x <= y) then end; if not (x <= y) then end;
        if not (x <= y) then end; if not (x <= y) then end; if not (x <= y) then end; if not (x <= y) then end; if not (x <= y) then end;
        if not (x <= y) then end; if not (x <= y) then end; if not (x <= y) then end; if not (x <= y) then end; if not (x <= y) then end;
    end
    return os.clock() - tm, 20
end)

------------------------------------------------------------------------------
-- ISEQV
------------------------------------------------------------------------------

bench("ISEQV", "taken", function(n)
    local x, y = 1, 1
    local tm = os.clock()
    for i = 1,n do
        if x ~= y then end; if x ~= y then end; if x ~= y then end; if x ~= y then end; if x ~= y then end;
        if x ~= y then end; if x ~= y then end; if x ~= y then end; if x ~= y then end; if x ~= y then end;
        if x ~= y then end; if x ~= y then end; if x ~= y then end; if x ~= y then end; if x ~= y then end;
        if x ~= y then end; if x ~= y then end; if x ~= y then end; if x ~= y then end; if x ~= y then end;
    end
    return os.clock() - tm, 20
end)

bench("ISEQV", "not taken", function(n)
    local x, y = 0, 1
    local tm = os.clock()
    for i = 1,n do
        if x ~= y then end; if x ~= y then end; if x ~= y then end; if x ~= y then end; if x ~= y then end;
        if x ~= y then end; if x ~= y then end; if x ~= y then end; if x ~= y then end; if x ~= y then end;
        if x ~= y then end; if x ~= y then end; if x ~= y then end; if x ~= y then end; if x ~= y then end;
        if x ~= y then end; if x ~= y then end; if x ~= y then end; if x ~= y then end; if x ~= y then end;
    end
    return os.clock() - tm, 20
end)

------------------------------------------------------------------------------
-- ISNEV
------------------------------------------------------------------------------

bench("ISNEV", "taken", function(n)
    local x, y = 0, 1
    local tm = os.clock()
    for i = 1,n do
        if x == y then end; if x == y then end; if x == y then end; if x == y then end; if x == y then end;
        if x == y then end; if x == y then end; if x == y then end; if x == y then end; if x == y then end;
        if x == y then end; if x == y then end; if x == y then end; if x == y then end; if x == y then end;
        if x == y then end; if x == y then end; if x == y then end; if x == y then end; if x == y then end;
    end
    return os.clock() - tm, 20
end)

bench("ISNEV", "not taken", function(n)
    local x, y = 1, 1
    local tm = os.clock()
    for i = 1,n do
        if x == y then end; if x == y then end; if x == y then end; if x == y then end; if x == y then end;
        if x == y then end; if x == y then end; if x == y then end; if x == y then end; if x == y then end;
        if x == y then end; if x == y then end; if x == y then end; if x == y then end; if x == y then end;
        if x == y then end; if x == y then end; if x == y then end; if x == y then end; if x == y then end;
    end
    return os.clock() - tm, 20
end)

------------------------------------------------------------------------------
-- ISEQS
------------------------------------------------------------------------------

bench("ISEQS", "taken", function(n)
    local x = "foo"
    local tm = os.clock()
    for i = 1,n do
        if x ~= "foo" then end; if x ~= "foo" then end; if x ~= "foo" then end; if x ~= "foo" then end; if x ~= "foo" then end;
        if x ~= "foo" then end; if x ~= "foo" then end; if x ~= "foo" then end; if x ~= "foo" then end; if x ~= "foo" then end;
        if x ~= "foo" then end; if x ~= "foo" then end; if x ~= "foo" then end; if x ~= "foo" then end; if x ~= "foo" then end;
        if x ~= "foo" then end; if x ~= "foo" then end; if x ~= "foo" then end; if x ~= "foo" then end; if x ~= "foo" then end;
    end
    return os.clock() - tm, 20
end)

bench("ISEQS", "not taken", function(n)
    local x = "bar"
    local tm = os.clock()
    for i = 1,n do
        if x ~= "foo" then end; if x ~= "foo" then end; if x ~= "foo" then end; if x ~= "foo" then end; if x ~= "foo" then end;
        if x ~= "foo" then end; if x ~= "foo" then end; if x ~= "foo" then end; if x ~= "foo" then end; if x ~= "foo" then end;
        if x ~= "foo" then end; if x ~= "foo" then end; if x ~= "foo" then end; if x ~= "foo" then end; if x ~= "foo" then end;
        if x ~= "foo" then end; if x ~= "foo" then end; if x ~= "foo" then end; if x ~= "foo" then end; if x ~= "foo" then end;
    end
    return os.clock() - tm, 20
end)

------------------------------------------------------------------------------
-- ISNES
------------------------------------------------------------------------------

bench("ISNES", "taken", function(n)
    local x = "bar"
    local tm = os.clock()
    for i = 1,n do
        if x == "foo" then end; if x == "foo" then end; if x == "foo" then end; if x == "foo" then end; if x == "foo" then end;
        if x == "foo" then end; if x == "foo" then end; if x == "foo" then end; if x == "foo" then end; if x == "foo" then end;
        if x == "foo" then end; if x == "foo" then end; if x == "foo" then end; if x == "foo" then end; if x == "foo" then end;
        if x == "foo" then end; if x == "foo" then end; if x == "foo" then end; if x == "foo" then end; if x == "foo" then end;
    end
    return os.clock() - tm, 20
end)

bench("ISNES", "not taken", function(n)
    local x = "foo"
    local tm = os.clock()
    for i = 1,n do
        if x == "foo" then end; if x == "foo" then end; if x == "foo" then end; if x == "foo" then end; if x == "foo" then end;
        if x == "foo" then end; if x == "foo" then end; if x == "foo" then end; if x == "foo" then end; if x == "foo" then end;
        if x == "foo" then end; if x == "foo" then end; if x == "foo" then end; if x == "foo" then end; if x == "foo" then end;
        if x == "foo" then end; if x == "foo" then end; if x == "foo" then end; if x == "foo" then end; if x == "foo" then end;
    end
    return os.clock() - tm, 20
end)

------------------------------------------------------------------------------
-- ISEQN
------------------------------------------------------------------------------

bench("ISEQN", "taken", function(n)
    local x = 1
    local tm = os.clock()
    for i = 1,n do
        if x ~= 1 then end; if x ~= 1 then end; if x ~= 1 then end; if x ~= 1 then end; if x ~= 1 then end;
        if x ~= 1 then end; if x ~= 1 then end; if x ~= 1 then end; if x ~= 1 then end; if x ~= 1 then end;
        if x ~= 1 then end; if x ~= 1 then end; if x ~= 1 then end; if x ~= 1 then end; if x ~= 1 then end;
        if x ~= 1 then end; if x ~= 1 then end; if x ~= 1 then end; if x ~= 1 then end; if x ~= 1 then end;
    end
    return os.clock() - tm, 20
end)

bench("ISEQN", "not taken", function(n)
    local x = 0
    local tm = os.clock()
    for i = 1,n do
        if x ~= 1 then end; if x ~= 1 then end; if x ~= 1 then end; if x ~= 1 then end; if x ~= 1 then end;
        if x ~= 1 then end; if x ~= 1 then end; if x ~= 1 then end; if x ~= 1 then end; if x ~= 1 then end;
        if x ~= 1 then end; if x ~= 1 then end; if x ~= 1 then end; if x ~= 1 then end; if x ~= 1 then end;
        if x ~= 1 then end; if x ~= 1 then end; if x ~= 1 then end; if x ~= 1 then end; if x ~= 1 then end;
    end
    return os.clock() - tm, 20
end)

------------------------------------------------------------------------------
-- ISNEN
------------------------------------------------------------------------------

bench("ISNEN", "taken", function(n)
    local x = 0
    local tm = os.clock()
    for i = 1,n do
        if x == 1 then end; if x == 1 then end; if x == 1 then end; if x == 1 then end; if x == 1 then end;
        if x == 1 then end; if x == 1 then end; if x == 1 then end; if x == 1 then end; if x == 1 then end;
        if x == 1 then end; if x == 1 then end; if x == 1 then end; if x == 1 then end; if x == 1 then end;
        if x == 1 then end; if x == 1 then end; if x == 1 then end; if x == 1 then end; if x == 1 then end;
    end
    return os.clock() - tm, 20
end)

bench("ISNEN", "not taken", function(n)
    local x = 1
    local tm = os.clock()
    for i = 1,n do
        if x == 1 then end; if x == 1 then end; if x == 1 then end; if x == 1 then end; if x == 1 then end;
        if x == 1 then end; if x == 1 then end; if x == 1 then end; if x == 1 then end; if x == 1 then end;
        if x == 1 then end; if x == 1 then end; if x == 1 then end; if x == 1 then end; if x == 1 then end;
        if x == 1 then end; if x == 1 then end; if x == 1 then end; if x == 1 then end; if x == 1 then end;
    end
    return os.clock() - tm, 20
end)

------------------------------------------------------------------------------
-- ISEQP
------------------------------------------------------------------------------

bench("ISEQP", "taken", function(n)
    local x = 1
    local tm = os.clock()
    for i = 1,n do
        if x ~= nil then end; if x ~= nil then end; if x ~= nil then end; if x ~= nil then end; if x ~= nil then end;
        if x ~= nil then end; if x ~= nil then end; if x ~= nil then end; if x ~= nil then end; if x ~= nil then end;
        if x ~= nil then end; if x ~= nil then end; if x ~= nil then end; if x ~= nil then end; if x ~= nil then end;
        if x ~= nil then end; if x ~= nil then end; if x ~= nil then end; if x ~= nil then end; if x ~= nil then end;
    end
    return os.clock() - tm, 20
end)

bench("ISEQP", "not taken", function(n)
    local x = 0
    local tm = os.clock()
    for i = 1,n do
        if x ~= nil then end; if x ~= nil then end; if x ~= nil then end; if x ~= nil then end; if x ~= nil then end;
        if x ~= nil then end; if x ~= nil then end; if x ~= nil then end; if x ~= nil then end; if x ~= nil then end;
        if x ~= nil then end; if x ~= nil then end; if x ~= nil then end; if x ~= nil then end; if x ~= nil then end;
        if x ~= nil then end; if x ~= nil then end; if x ~= nil then end; if x ~= nil then end; if x ~= nil then end;
    end
    return os.clock() - tm, 20
end)

------------------------------------------------------------------------------
-- ISNEP
------------------------------------------------------------------------------

bench("ISNEP", "taken", function(n)
    local x = 0
    local tm = os.clock()
    for i = 1,n do
        if x == nil then end; if x == nil then end; if x == nil then end; if x == nil then end; if x == nil then end;
        if x == nil then end; if x == nil then end; if x == nil then end; if x == nil then end; if x == nil then end;
        if x == nil then end; if x == nil then end; if x == nil then end; if x == nil then end; if x == nil then end;
        if x == nil then end; if x == nil then end; if x == nil then end; if x == nil then end; if x == nil then end;
    end
    return os.clock() - tm, 20
end)

bench("ISNEP", "not taken", function(n)
    local x = 1
    local tm = os.clock()
    for i = 1,n do
        if x == nil then end; if x == nil then end; if x == nil then end; if x == nil then end; if x == nil then end;
        if x == nil then end; if x == nil then end; if x == nil then end; if x == nil then end; if x == nil then end;
        if x == nil then end; if x == nil then end; if x == nil then end; if x == nil then end; if x == nil then end;
        if x == nil then end; if x == nil then end; if x == nil then end; if x == nil then end; if x == nil then end;
    end
    return os.clock() - tm, 20
end)

------------------------------------------------------------------------------
-- ISTC
------------------------------------------------------------------------------

bench("ISTC", "taken", function(n)
    local x, y, z = 1, 1, 0
    local tm = os.clock()
    for i = 1,n do
        z = x or y; z = x or y; z = x or y; z = x or y; z = x or y;
        z = x or y; z = x or y; z = x or y; z = x or y; z = x or y;
        z = x or y; z = x or y; z = x or y; z = x or y; z = x or y;
        z = x or y; z = x or y; z = x or y; z = x or y; z = x or y;
    end
    return os.clock() - tm, 20
end)

bench("ISTC", "not taken", function(n)
    local x, y, z = nil, 1, 0
    local tm = os.clock()
    for i = 1,n do
        z = x or y; z = x or y; z = x or y; z = x or y; z = x or y;
        z = x or y; z = x or y; z = x or y; z = x or y; z = x or y;
        z = x or y; z = x or y; z = x or y; z = x or y; z = x or y;
        z = x or y; z = x or y; z = x or y; z = x or y; z = x or y;
    end
    return os.clock() - tm, 20
end)

------------------------------------------------------------------------------
-- ISFC
------------------------------------------------------------------------------

bench("ISFC", "taken", function(n)
    local x, y, z = nil, 1, 0
    local tm = os.clock()
    for i = 1,n do
        z = x and y; z = x and y; z = x and y; z = x and y; z = x and y;
        z = x and y; z = x and y; z = x and y; z = x and y; z = x and y;
        z = x and y; z = x and y; z = x and y; z = x and y; z = x and y;
        z = x and y; z = x and y; z = x and y; z = x and y; z = x and y;
    end
    return os.clock() - tm, 20
end)

bench("ISFC", "not taken", function(n)
    local x, y, z = 1, 1, 0
    local tm = os.clock()
    for i = 1,n do
        z = x and y; z = x and y; z = x and y; z = x and y; z = x and y;
        z = x and y; z = x and y; z = x and y; z = x and y; z = x and y;
        z = x and y; z = x and y; z = x and y; z = x and y; z = x and y;
        z = x and y; z = x and y; z = x and y; z = x and y; z = x and y;
    end
    return os.clock() - tm, 20
end)

------------------------------------------------------------------------------
-- IST
------------------------------------------------------------------------------

bench("IST", "taken", function(n)
    local x = true
    local tm = os.clock()
    for i = 1,n do
        if not x then end; if not x then end; if not x then end; if not x then end; if not x then end;
        if not x then end; if not x then end; if not x then end; if not x then end; if not x then end;
        if not x then end; if not x then end; if not x then end; if not x then end; if not x then end;
        if not x then end; if not x then end; if not x then end; if not x then end; if not x then end;
    end
    return os.clock() - tm, 20
end)

bench("IST", "not taken", function(n)
    local x = false
    local tm = os.clock()
    for i = 1,n do
        if not x then end; if not x then end; if not x then end; if not x then end; if not x then end;
        if not x then end; if not x then end; if not x then end; if not x then end; if not x then end;
        if not x then end; if not x then end; if not x then end; if not x then end; if not x then end;
        if not x then end; if not x then end; if not x then end; if not x then end; if not x then end;
    end
    return os.clock() - tm, 20
end)

------------------------------------------------------------------------------
-- ISF
------------------------------------------------------------------------------

bench("ISF", "taken", function(n)
    local x = false
    local tm = os.clock()
    for i = 1,n do
        if x then end; if x then end; if x then end; if x then end; if x then end;
        if x then end; if x then end; if x then end; if x then end; if x then end;
        if x then end; if x then end; if x then end; if x then end; if x then end;
        if x then end; if x then end; if x then end; if x then end; if x then end;
    end
    return os.clock() - tm, 20
end)

bench("ISF", "not taken", function(n)
    local x = true
    local tm = os.clock()
    for i = 1,n do
        if x then end; if x then end; if x then end; if x then end; if x then end;
        if x then end; if x then end; if x then end; if x then end; if x then end;
        if x then end; if x then end; if x then end; if x then end; if x then end;
        if x then end; if x then end; if x then end; if x then end; if x then end;
    end
    return os.clock() - tm, 20
end)

-- TODO: ISTYPE, luajit builtin functions
-- TODO: ISNUM, luajit builtin functions

------------------------------------------------------------------------------
-- MOV
------------------------------------------------------------------------------

bench("MOV", "r = x", function(n)
    local x, r = 0, 0
    local tm = os.clock()
    for i = 1,n do
        r = x; r = x; r = x; r = x; r = x;
        r = x; r = x; r = x; r = x; r = x;
        r = x; r = x; r = x; r = x; r = x;
        r = x; r = x; r = x; r = x; r = x;
    end
    return os.clock() - tm, 20
end)

------------------------------------------------------------------------------
-- NOT
------------------------------------------------------------------------------

bench("NOT", "x = not x", function(n)
    local x = false
    local tm = os.clock()
    for i = 1,n do
        x = not x; x = not x; x = not x; x = not x; x = not x;
        x = not x; x = not x; x = not x; x = not x; x = not x;
        x = not x; x = not x; x = not x; x = not x; x = not x;
        x = not x; x = not x; x = not x; x = not x; x = not x;
    end
    return os.clock() - tm, 20
end)

bench("NOT", "r = not x", function(n)
    local x, r = false, false
    local tm = os.clock()
    for i = 1,n do
        r = not x; r = not x; r = not x; r = not x; r = not x;
        r = not x; r = not x; r = not x; r = not x; r = not x;
        r = not x; r = not x; r = not x; r = not x; r = not x;
        r = not x; r = not x; r = not x; r = not x; r = not x;
    end
    return os.clock() - tm, 20
end)

------------------------------------------------------------------------------
-- UNM
------------------------------------------------------------------------------

bench("UNM", "x = -x", function(n)
    local x = 1
    local tm = os.clock()
    for i = 1,n do
        x = -x; x = -x; x = -x; x = -x; x = -x;
        x = -x; x = -x; x = -x; x = -x; x = -x;
        x = -x; x = -x; x = -x; x = -x; x = -x;
        x = -x; x = -x; x = -x; x = -x; x = -x;
    end
    return os.clock() - tm, 20
end)

bench("UNM", "r = -x", function(n)
    local x, r = 1, 0
    local tm = os.clock()
    for i = 1,n do
        r = -x; r = -x; r = -x; r = -x; r = -x;
        r = -x; r = -x; r = -x; r = -x; r = -x;
        r = -x; r = -x; r = -x; r = -x; r = -x;
        r = -x; r = -x; r = -x; r = -x; r = -x;
    end
    return os.clock() - tm, 20
end)

------------------------------------------------------------------------------
-- LEN
------------------------------------------------------------------------------

bench("LEN", "r = #table", function(n)
    local t = {0,1,2,3,4,5,6,7,8,9}
    local r = 0
    local tm = os.clock()
    for i = 1,n do
        r = #t; r = #t; r = #t; r = #t; r = #t;
        r = #t; r = #t; r = #t; r = #t; r = #t;
        r = #t; r = #t; r = #t; r = #t; r = #t;
        r = #t; r = #t; r = #t; r = #t; r = #t;
    end
    return os.clock() - tm, 20
end)

bench("LEN", "r = #str", function(n)
    local s = "foobar"
    local r = 0
    local tm = os.clock()
    for i = 1,n do
        r = #s; r = #s; r = #s; r = #s; r = #s;
        r = #s; r = #s; r = #s; r = #s; r = #s;
        r = #s; r = #s; r = #s; r = #s; r = #s;
        r = #s; r = #s; r = #s; r = #s; r = #s;
    end
    return os.clock() - tm, 20
end)

------------------------------------------------------------------------------
-- ADDVV, ADDVN, ADDNV
------------------------------------------------------------------------------

bench("ADDVN", "x = x + 1", function(n)
    local x = 0
    local tm = os.clock()
    for i = 1,n do
        x = x + 1; x = x + 1; x = x + 1; x = x + 1; x = x + 1;
        x = x + 1; x = x + 1; x = x + 1; x = x + 1; x = x + 1;
        x = x + 1; x = x + 1; x = x + 1; x = x + 1; x = x + 1;
        x = x + 1; x = x + 1; x = x + 1; x = x + 1; x = x + 1;
    end
    return os.clock() - tm, 20
end)

bench("ADDVN", "r = x + 1", function(n)
    local r, x = 0, 0
    local tm = os.clock()
    for i = 1,n do
        r = x + 1; r = x + 1; r = x + 1; r = x + 1; r = x + 1;
        r = x + 1; r = x + 1; r = x + 1; r = x + 1; r = x + 1;
        r = x + 1; r = x + 1; r = x + 1; r = x + 1; r = x + 1;
        r = x + 1; r = x + 1; r = x + 1; r = x + 1; r = x + 1;
    end
    return os.clock() - tm, 20
end)

bench("ADDVV", "x = x + y", function(n)
    local x, y = 2, 3
    local tm = os.clock()
    for i = 1,n do
        x = x + y; x = x + y; x = x + y; x = x + y; x = x + y;
        x = x + y; x = x + y; x = x + y; x = x + y; x = x + y;
        x = x + y; x = x + y; x = x + y; x = x + y; x = x + y;
        x = x + y; x = x + y; x = x + y; x = x + y; x = x + y;
    end
    return os.clock() - tm, 20
end)

bench("ADDVV", "r = x + y", function(n)
    local x, y, r = 2, 3, 0
    local tm = os.clock()
    for i = 1,n do
        r = x + y; r = x + y; r = x + y; r = x + y; r = x + y;
        r = x + y; r = x + y; r = x + y; r = x + y; r = x + y;
        r = x + y; r = x + y; r = x + y; r = x + y; r = x + y;
        r = x + y; r = x + y; r = x + y; r = x + y; r = x + y;
    end
    return os.clock() - tm, 20
end)

------------------------------------------------------------------------------
-- SUBVV, SUBVN, SUBNV
------------------------------------------------------------------------------

bench("SUBVN", "x = x - 1", function(n)
    local x = 3
    local tm = os.clock()
    for i = 1,n do
        x = x - 1; x = x - 1; x = x - 1; x = x - 1; x = x - 1;
        x = x - 1; x = x - 1; x = x - 1; x = x - 1; x = x - 1;
        x = x - 1; x = x - 1; x = x - 1; x = x - 1; x = x - 1;
        x = x - 1; x = x - 1; x = x - 1; x = x - 1; x = x - 1;
    end
    return os.clock() - tm, 20
end)

bench("SUBVN", "r = x - 1", function(n)
    local r, x = 3, 2
    local tm = os.clock()
    for i = 1,n do
        r = x - 1; r = x - 1; r = x - 1; r = x - 1; r = x - 1;
        r = x - 1; r = x - 1; r = x - 1; r = x - 1; r = x - 1;
        r = x - 1; r = x - 1; r = x - 1; r = x - 1; r = x - 1;
        r = x - 1; r = x - 1; r = x - 1; r = x - 1; r = x - 1;
    end
    return os.clock() - tm, 20
end)

bench("SUBVV", "x = x - y", function(n)
    local x, y = 3, 2
    local tm = os.clock()
    for i = 1,n do
        x = x - y; x = x - y; x = x - y; x = x - y; x = x - y;
        x = x - y; x = x - y; x = x - y; x = x - y; x = x - y;
        x = x - y; x = x - y; x = x - y; x = x - y; x = x - y;
        x = x - y; x = x - y; x = x - y; x = x - y; x = x - y;
    end
    return os.clock() - tm, 20
end)

bench("SUBVV", "r = x - y", function(n)
    local x, y, r = 3, 2, 0
    local tm = os.clock()
    for i = 1,n do
        r = x - y; r = x - y; r = x - y; r = x - y; r = x - y;
        r = x - y; r = x - y; r = x - y; r = x - y; r = x - y;
        r = x - y; r = x - y; r = x - y; r = x - y; r = x - y;
        r = x - y; r = x - y; r = x - y; r = x - y; r = x - y;
    end
    return os.clock() - tm, 20
end)

------------------------------------------------------------------------------
-- MULVV, MULVN, MULNV
------------------------------------------------------------------------------

bench("MULVN", "x = x * 1", function(n)
    local x = 1
    local tm = os.clock()
    for i = 1,n do
        x = x * 1; x = x * 1; x = x * 1; x = x * 1; x = x * 1;
        x = x * 1; x = x * 1; x = x * 1; x = x * 1; x = x * 1;
        x = x * 1; x = x * 1; x = x * 1; x = x * 1; x = x * 1;
        x = x * 1; x = x * 1; x = x * 1; x = x * 1; x = x * 1;
    end
    return os.clock() - tm, 20
end)

bench("MULVV", "x = x * y", function(n)
    local x, y = 1, 1
    local tm = os.clock()
    for i = 1,n do
        x = x * y; x = x * y; x = x * y; x = x * y; x = x * y;
        x = x * y; x = x * y; x = x * y; x = x * y; x = x * y;
        x = x * y; x = x * y; x = x * y; x = x * y; x = x * y;
        x = x * y; x = x * y; x = x * y; x = x * y; x = x * y;
    end
    return os.clock() - tm, 20
end)

bench("MULVV", "r = x * y", function(n)
    local x, y, r = 1, 1, 0
    local tm = os.clock()
    for i = 1,n do
        r = x * y; r = x * y; r = x * y; r = x * y; r = x * y;
        r = x * y; r = x * y; r = x * y; r = x * y; r = x * y;
        r = x * y; r = x * y; r = x * y; r = x * y; r = x * y;
        r = x * y; r = x * y; r = x * y; r = x * y; r = x * y;
    end
    return os.clock() - tm, 20
end)

------------------------------------------------------------------------------
-- DIVVV, DIVVN, DIVNV
------------------------------------------------------------------------------

bench("DIVVN", "x = x / 1", function(n)
    local x = 1
    local tm = os.clock()
    for i = 1,n do
        x = x / 1; x = x / 1; x = x / 1; x = x / 1; x = x / 1;
        x = x / 1; x = x / 1; x = x / 1; x = x / 1; x = x / 1;
        x = x / 1; x = x / 1; x = x / 1; x = x / 1; x = x / 1;
        x = x / 1; x = x / 1; x = x / 1; x = x / 1; x = x / 1;
    end
    return os.clock() - tm, 20
end)

bench("DIVVN", "r = x / 1", function(n)
    local x, r = 1, 0
    local tm = os.clock()
    for i = 1,n do
        r = x / 1; r = x / 1; r = x / 1; r = x / 1; r = x / 1;
        r = x / 1; r = x / 1; r = x / 1; r = x / 1; r = x / 1;
        r = x / 1; r = x / 1; r = x / 1; r = x / 1; r = x / 1;
        r = x / 1; r = x / 1; r = x / 1; r = x / 1; r = x / 1;
    end
    return os.clock() - tm, 20
end)

bench("DIVVV", "x = x / y", function(n)
    local x, y = 1, 1
    local tm = os.clock()
    for i = 1,n do
        x = x / y; x = x / y; x = x / y; x = x / y; x = x / y;
        x = x / y; x = x / y; x = x / y; x = x / y; x = x / y;
        x = x / y; x = x / y; x = x / y; x = x / y; x = x / y;
        x = x / y; x = x / y; x = x / y; x = x / y; x = x / y;
    end
    return os.clock() - tm, 20
end)

bench("DIVVV", "r = x / y", function(n)
    local x, y, r = 1, 1, 0
    local tm = os.clock()
    for i = 1,n do
        r = x / y; r = x / y; r = x / y; r = x / y; r = x / y;
        r = x / y; r = x / y; r = x / y; r = x / y; r = x / y;
        r = x / y; r = x / y; r = x / y; r = x / y; r = x / y;
        r = x / y; r = x / y; r = x / y; r = x / y; r = x / y;
    end
    return os.clock() - tm, 20
end)

------------------------------------------------------------------------------
-- MODVV, MODVN, MODNV
------------------------------------------------------------------------------

bench("MODVN", "x = x % 3", function(n)
    local x = 1
    local tm = os.clock()
    for i = 1,n do
        x = x % 3; x = x % 3; x = x % 3; x = x % 3; x = x % 3;
        x = x % 3; x = x % 3; x = x % 3; x = x % 3; x = x % 3;
        x = x % 3; x = x % 3; x = x % 3; x = x % 3; x = x % 3;
        x = x % 3; x = x % 3; x = x % 3; x = x % 3; x = x % 3;
    end
    return os.clock() - tm, 20
end)

bench("MODVN", "r = x % 3", function(n)
    local x, r = 1, 0
    local tm = os.clock()
    for i = 1,n do
        r = x % 3; r = x % 3; r = x % 3; r = x % 3; r = x % 3;
        r = x % 3; r = x % 3; r = x % 3; r = x % 3; r = x % 3;
        r = x % 3; r = x % 3; r = x % 3; r = x % 3; r = x % 3;
        r = x % 3; r = x % 3; r = x % 3; r = x % 3; r = x % 3;
    end
    return os.clock() - tm, 20
end)

bench("MODVV", "x = x % y", function(n)
    local x, y = 1, 3
    local tm = os.clock()
    for i = 1,n do
        x = x % y; x = x % y; x = x % y; x = x % y; x = x % y;
        x = x % y; x = x % y; x = x % y; x = x % y; x = x % y;
        x = x % y; x = x % y; x = x % y; x = x % y; x = x % y;
        x = x % y; x = x % y; x = x % y; x = x % y; x = x % y;
    end
    return os.clock() - tm, 20
end)

bench("MODVV", "r = x % y", function(n)
    local x, y, r = 1, 1, 0
    local tm = os.clock()
    for i = 1,n do
        r = x % y; r = x % y; r = x % y; r = x % y; r = x % y;
        r = x % y; r = x % y; r = x % y; r = x % y; r = x % y;
        r = x % y; r = x % y; r = x % y; r = x % y; r = x % y;
        r = x % y; r = x % y; r = x % y; r = x % y; r = x % y;
    end
    return os.clock() - tm, 20
end)

------------------------------------------------------------------------------
-- POW
------------------------------------------------------------------------------

bench("POW", "x = x ^ y", function(n)
    local x, y, r = 1, 1, 0
    local tm = os.clock()
    for i = 1,n do
        r = x ^ y; r = x ^ y; r = x ^ y; r = x ^ y; r = x ^ y;
        r = x ^ y; r = x ^ y; r = x ^ y; r = x ^ y; r = x ^ y;
        r = x ^ y; r = x ^ y; r = x ^ y; r = x ^ y; r = x ^ y;
        r = x ^ y; r = x ^ y; r = x ^ y; r = x ^ y; r = x ^ y;
    end
    return os.clock() - tm, 20
end)

------------------------------------------------------------------------------
-- CAT
------------------------------------------------------------------------------

bench("CAT", "r = x..y", function(n)
    local x, y, r = "foo", "bar", nil
    local tm = os.clock()
    for i = 1,n do
        r = x..y; r = x..y; r = x..y; r = x..y; r = x..y;
        r = x..y; r = x..y; r = x..y; r = x..y; r = x..y;
        r = x..y; r = x..y; r = x..y; r = x..y; r = x..y;
        r = x..y; r = x..y; r = x..y; r = x..y; r = x..y;
    end
    return os.clock() - tm, 20
end)

------------------------------------------------------------------------------
-- KSTR
------------------------------------------------------------------------------

bench("KSTR", "r = \"foo\"", function(n)
    local r = nil
    local tm = os.clock()
    for i = 1,n do
        r = "foo"; r = "foo"; r = "foo"; r = "foo"; r = "foo";
        r = "foo"; r = "foo"; r = "foo"; r = "foo"; r = "foo";
        r = "foo"; r = "foo"; r = "foo"; r = "foo"; r = "foo";
        r = "foo"; r = "foo"; r = "foo"; r = "foo"; r = "foo";
    end
    return os.clock() - tm, 20
end)

------------------------------------------------------------------------------
-- KCDATA
------------------------------------------------------------------------------

-- TODO: KCDATA

------------------------------------------------------------------------------
-- KSHORT
------------------------------------------------------------------------------

bench("KSHORT", "r = 0", function(n)
    local r = nil
    local tm = os.clock()
    for i = 1,n do
        r = 0; r = 0; r = 0; r = 0; r = 0;
        r = 0; r = 0; r = 0; r = 0; r = 0;
        r = 0; r = 0; r = 0; r = 0; r = 0;
        r = 0; r = 0; r = 0; r = 0; r = 0;
    end
    return os.clock() - tm, 20
end)

------------------------------------------------------------------------------
-- KNUM
------------------------------------------------------------------------------

bench("KNUM", "r = 123456", function(n)
    local r = nil
    local tm = os.clock()
    for i = 1,n do
        r = 123456; r = 123456; r = 123456; r = 123456; r = 123456;
        r = 123456; r = 123456; r = 123456; r = 123456; r = 123456;
        r = 123456; r = 123456; r = 123456; r = 123456; r = 123456;
        r = 123456; r = 123456; r = 123456; r = 123456; r = 123456;
    end
    return os.clock() - tm, 20
end)

------------------------------------------------------------------------------
-- KPRI
------------------------------------------------------------------------------

bench("KPRI", "r = true", function(n)
    local r = nil
    local tm = os.clock()
    for i = 1,n do
        r = true; r = true; r = true; r = true; r = true;
        r = true; r = true; r = true; r = true; r = true;
        r = true; r = true; r = true; r = true; r = true;
        r = true; r = true; r = true; r = true; r = true;
    end
    return os.clock() - tm, 20
end)

------------------------------------------------------------------------------
-- KNIL
------------------------------------------------------------------------------

bench("KNIL", "local x, y = nil, nil; local z = 0", function(n)
    local tm = os.clock()
    for i = 1,n do
        local x, y = nil, nil; local z = 0;
        local x, y = nil, nil; local z = 0;
        local x, y = nil, nil; local z = 0;
        local x, y = nil, nil; local z = 0;
        local x, y = nil, nil; local z = 0;
        local x, y = nil, nil; local z = 0;
        local x, y = nil, nil; local z = 0;
        local x, y = nil, nil; local z = 0;
        local x, y = nil, nil; local z = 0;
        local x, y = nil, nil; local z = 0;
        local x, y = nil, nil; local z = 0;
        local x, y = nil, nil; local z = 0;
        local x, y = nil, nil; local z = 0;
        local x, y = nil, nil; local z = 0;
        local x, y = nil, nil; local z = 0;
        local x, y = nil, nil; local z = 0;
        local x, y = nil, nil; local z = 0;
        local x, y = nil, nil; local z = 0;
        local x, y = nil, nil; local z = 0;
        local x, y = nil, nil; local z = 0;
    end
    return os.clock() - tm, 20
end)

bench("KNIL", "local x = nil -- x10", function(n)
    local tm = os.clock()
    for i = 1,n do
        local x = nil; local x = nil; local x = nil; local x = nil; local x = nil;
        local x = nil; local x = nil; local x = nil; local x = nil; local x = nil;
    end
    return os.clock() - tm, 1
end)

bench("KNIL", "local x = nil -- x25", function(n)
    local tm = os.clock()
    for i = 1,n do
        local x = nil; local x = nil; local x = nil; local x = nil; local x = nil;
        local x = nil; local x = nil; local x = nil; local x = nil; local x = nil;
        local x = nil; local x = nil; local x = nil; local x = nil; local x = nil;
        local x = nil; local x = nil; local x = nil; local x = nil; local x = nil;
        local x = nil; local x = nil; local x = nil; local x = nil; local x = nil;
    end
    return os.clock() - tm, 1
end)

bench("KNIL", "local x = nil -- x50", function(n)
    local tm = os.clock()
    for i = 1,n do
        local x = nil; local x = nil; local x = nil; local x = nil; local x = nil;
        local x = nil; local x = nil; local x = nil; local x = nil; local x = nil;
        local x = nil; local x = nil; local x = nil; local x = nil; local x = nil;
        local x = nil; local x = nil; local x = nil; local x = nil; local x = nil;
        local x = nil; local x = nil; local x = nil; local x = nil; local x = nil;
        local x = nil; local x = nil; local x = nil; local x = nil; local x = nil;
        local x = nil; local x = nil; local x = nil; local x = nil; local x = nil;
        local x = nil; local x = nil; local x = nil; local x = nil; local x = nil;
        local x = nil; local x = nil; local x = nil; local x = nil; local x = nil;
        local x = nil; local x = nil; local x = nil; local x = nil; local x = nil;
    end
    return os.clock() - tm, 1
end)

------------------------------------------------------------------------------
-- UGET
------------------------------------------------------------------------------

bench("UGET", "r = x", function(n)
    local x = 0
    local function run(n)
        local r = nil
        local tm = os.clock()
        for i = 1,n do
            r = x; r = x; r = x; r = x; r = x;
            r = x; r = x; r = x; r = x; r = x;
            r = x; r = x; r = x; r = x; r = x;
            r = x; r = x; r = x; r = x; r = x;
        end
        return os.clock() - tm, 20
    end
    return run(n)
end)

------------------------------------------------------------------------------
-- USETV
------------------------------------------------------------------------------

bench("USETV", "r = x", function(n)
    local r = nil
    local function run(n)
        local x = 0
        local tm = os.clock()
        for i = 1,n do
            r = x; r = x; r = x; r = x; r = x;
            r = x; r = x; r = x; r = x; r = x;
            r = x; r = x; r = x; r = x; r = x;
            r = x; r = x; r = x; r = x; r = x;
        end
        return os.clock() - tm, 20
    end
    return run(n)
end)

bench("USETV", "r = x -- upval", function(n)
    local r = nil
    local x = 0
    local function run(n)
        local tm = os.clock()
        for i = 1,n do
            r = x; r = x; r = x; r = x; r = x;
            r = x; r = x; r = x; r = x; r = x;
            r = x; r = x; r = x; r = x; r = x;
            r = x; r = x; r = x; r = x; r = x;
        end
        return os.clock() - tm, 20
    end
    return run(n)
end)

bench("USETV", "x = x", function(n)
    local x = 0
    local function run(n)
        local tm = os.clock()
        for i = 1,n do
            x = x; x = x; x = x; x = x; x = x;
            x = x; x = x; x = x; x = x; x = x;
            x = x; x = x; x = x; x = x; x = x;
            x = x; x = x; x = x; x = x; x = x;
        end
        return os.clock() - tm, 20
    end
    return run(n)
end)

------------------------------------------------------------------------------
-- USETS
------------------------------------------------------------------------------

bench("USETS", "r = \"foo\"", function(n)
    local r = nil
    local function run(n)
        local tm = os.clock()
        for i = 1,n do
            r = "foo"; r = "foo"; r = "foo"; r = "foo"; r = "foo";
            r = "foo"; r = "foo"; r = "foo"; r = "foo"; r = "foo";
            r = "foo"; r = "foo"; r = "foo"; r = "foo"; r = "foo";
            r = "foo"; r = "foo"; r = "foo"; r = "foo"; r = "foo";
        end
        return os.clock() - tm, 20
    end
    return run(n)
end)

------------------------------------------------------------------------------
-- USETN
------------------------------------------------------------------------------

bench("USETN", "r = 0", function(n)
    local r = nil
    local function run(n)
        local tm = os.clock()
        for i = 1,n do
            r = 0; r = 0; r = 0; r = 0; r = 0;
            r = 0; r = 0; r = 0; r = 0; r = 0;
            r = 0; r = 0; r = 0; r = 0; r = 0;
            r = 0; r = 0; r = 0; r = 0; r = 0;
        end
        return os.clock() - tm, 20
    end
    return run(n)
end)

------------------------------------------------------------------------------
-- USETP
------------------------------------------------------------------------------

bench("USETP", "r = nil", function(n)
    local r = nil
    local function run(n)
        local tm = os.clock()
        for i = 1,n do
            r = nil; r = nil; r = nil; r = nil; r = nil;
            r = nil; r = nil; r = nil; r = nil; r = nil;
            r = nil; r = nil; r = nil; r = nil; r = nil;
            r = nil; r = nil; r = nil; r = nil; r = nil;
        end
        return os.clock() - tm, 20
    end
    return run(n)
end)

------------------------------------------------------------------------------
-- UCLO
------------------------------------------------------------------------------

-- TODO: UCLO

------------------------------------------------------------------------------
-- FNEW
------------------------------------------------------------------------------

bench("FNEW", "local function foo() end", function(n)
    local tm = os.clock()
    for i = 1,n do
        local function foo() end; local function foo() end;
        local function foo() end; local function foo() end;
        local function foo() end;
        local function foo() end; local function foo() end;
        local function foo() end; local function foo() end;
        local function foo() end;
        local function foo() end; local function foo() end;
        local function foo() end; local function foo() end;
        local function foo() end;
        local function foo() end; local function foo() end;
        local function foo() end; local function foo() end;
        local function foo() end;
    end
    return os.clock() - tm, 20
end)

------------------------------------------------------------------------------
-- TNEW
------------------------------------------------------------------------------

bench("TNEW", "r = {}", function(n)
    local r = {}
    local tm = os.clock()
    for i = 1,n do
        r = {}; r = {}; r = {}; r = {}; r = {};
        r = {}; r = {}; r = {}; r = {}; r = {};
        r = {}; r = {}; r = {}; r = {}; r = {};
        r = {}; r = {}; r = {}; r = {}; r = {};
    end
    return os.clock() - tm, 20
end)

------------------------------------------------------------------------------
-- TDUP
------------------------------------------------------------------------------

bench("TDUP", "r = {0}", function(n)
    local r = {}
    local tm = os.clock()
    for i = 1,n do
        r = {0}; r = {0}; r = {0}; r = {0}; r = {0};
        r = {0}; r = {0}; r = {0}; r = {0}; r = {0};
        r = {0}; r = {0}; r = {0}; r = {0}; r = {0};
        r = {0}; r = {0}; r = {0}; r = {0}; r = {0};
    end
    return os.clock() - tm, 20
end)

------------------------------------------------------------------------------
-- GGET
------------------------------------------------------------------------------

bench("GGET", "r = x", function(n)
    x = 0
    local r = nil
    local tm = os.clock()
    for i = 1,n do
        r = x; r = x; r = x; r = x; r = x;
        r = x; r = x; r = x; r = x; r = x;
        r = x; r = x; r = x; r = x; r = x;
        r = x; r = x; r = x; r = x; r = x;
    end
    return os.clock() - tm, 20
end)

------------------------------------------------------------------------------
-- GSET
------------------------------------------------------------------------------

bench("GSET", "r = x", function(n)
    local x = 0
    local tm = os.clock()
    for i = 1,n do
        r = x; r = x; r = x; r = x; r = x;
        r = x; r = x; r = x; r = x; r = x;
        r = x; r = x; r = x; r = x; r = x;
        r = x; r = x; r = x; r = x; r = x;
    end
    return os.clock() - tm, 20
end)

------------------------------------------------------------------------------
-- TGETV
------------------------------------------------------------------------------

bench("TGETV", "r = t[x] -- 1", function(n)
    local t = {1,2,3}
    local x, r = 1, nil
    local tm = os.clock()
    for i = 1,n do
        r = t[x]; r = t[x]; r = t[x]; r = t[x]; r = t[x];
        r = t[x]; r = t[x]; r = t[x]; r = t[x]; r = t[x];
        r = t[x]; r = t[x]; r = t[x]; r = t[x]; r = t[x];
        r = t[x]; r = t[x]; r = t[x]; r = t[x]; r = t[x];
    end
    return os.clock() - tm, 20
end)

bench("TGETV", "r = t[x] -- 4 (miss)", function(n)
    local t = {1,2,3}
    local x, r = 4, nil
    local tm = os.clock()
    for i = 1,n do
        r = t[x]; r = t[x]; r = t[x]; r = t[x]; r = t[x];
        r = t[x]; r = t[x]; r = t[x]; r = t[x]; r = t[x];
        r = t[x]; r = t[x]; r = t[x]; r = t[x]; r = t[x];
        r = t[x]; r = t[x]; r = t[x]; r = t[x]; r = t[x];
    end
    return os.clock() - tm, 20
end)

bench("TGETV", "r = t[x] -- 1000 (miss)", function(n)
    local t = {1,2,3}
    local x, r = 1000, nil
    local tm = os.clock()
    for i = 1,n do
        r = t[x]; r = t[x]; r = t[x]; r = t[x]; r = t[x];
        r = t[x]; r = t[x]; r = t[x]; r = t[x]; r = t[x];
        r = t[x]; r = t[x]; r = t[x]; r = t[x]; r = t[x];
        r = t[x]; r = t[x]; r = t[x]; r = t[x]; r = t[x];
    end
    return os.clock() - tm, 20
end)

bench("TGETV", "r = t[x] -- \"foo\"", function(n)
    local t = { foo = 1, bar = 2, baz = 3 }
    local x, r = "foo", nil
    local tm = os.clock()
    for i = 1,n do
        r = t[x]; r = t[x]; r = t[x]; r = t[x]; r = t[x];
        r = t[x]; r = t[x]; r = t[x]; r = t[x]; r = t[x];
        r = t[x]; r = t[x]; r = t[x]; r = t[x]; r = t[x];
        r = t[x]; r = t[x]; r = t[x]; r = t[x]; r = t[x];
    end
    return os.clock() - tm, 20
end)

bench("TGETV", "r = t[x] -- \"foo123\" (miss)", function(n)
    local t = { foo = 1, bar = 2, baz = 3 }
    local x, r = "foo123", nil
    local tm = os.clock()
    for i = 1,n do
        r = t[x]; r = t[x]; r = t[x]; r = t[x]; r = t[x];
        r = t[x]; r = t[x]; r = t[x]; r = t[x]; r = t[x];
        r = t[x]; r = t[x]; r = t[x]; r = t[x]; r = t[x];
        r = t[x]; r = t[x]; r = t[x]; r = t[x]; r = t[x];
    end
    return os.clock() - tm, 20
end)

------------------------------------------------------------------------------
-- TGETS
------------------------------------------------------------------------------

bench("TGETS", "r = t[\"foo\"]", function(n)
    local t = { foo = 1, bar = 2, baz = 3 }
    local r = nil
    local tm = os.clock()
    for i = 1,n do
        r = t["foo"]; r = t["foo"]; r = t["foo"]; r = t["foo"]; r = t["foo"];
        r = t["foo"]; r = t["foo"]; r = t["foo"]; r = t["foo"]; r = t["foo"];
        r = t["foo"]; r = t["foo"]; r = t["foo"]; r = t["foo"]; r = t["foo"];
        r = t["foo"]; r = t["foo"]; r = t["foo"]; r = t["foo"]; r = t["foo"];
    end
    return os.clock() - tm, 20
end)

bench("TGETS", "r = t[\"boo\"] -- miss", function(n)
    local t = { fo0 = 1, bar = 2, baz = 3 }
    local r = nil
    local tm = os.clock()
    for i = 1,n do
        r = t["boo"]; r = t["boo"]; r = t["boo"]; r = t["boo"]; r = t["boo"];
        r = t["boo"]; r = t["boo"]; r = t["boo"]; r = t["boo"]; r = t["boo"];
        r = t["boo"]; r = t["boo"]; r = t["boo"]; r = t["boo"]; r = t["boo"];
        r = t["boo"]; r = t["boo"]; r = t["boo"]; r = t["boo"]; r = t["boo"];
    end
    return os.clock() - tm, 20
end)

------------------------------------------------------------------------------
-- TGETB
------------------------------------------------------------------------------

bench("TGETB", "r = t[4]", function(n)
    local t = {0,1,2,3,4,5,6,7,8,9}
    local r = nil
    local tm = os.clock()
    for i = 1,n do
        r = t[4]; r = t[4]; r = t[4]; r = t[4]; r = t[4];
        r = t[4]; r = t[4]; r = t[4]; r = t[4]; r = t[4];
        r = t[4]; r = t[4]; r = t[4]; r = t[4]; r = t[4];
        r = t[4]; r = t[4]; r = t[4]; r = t[4]; r = t[4];
    end
    return os.clock() - tm, 20
end)

bench("TGETB", "r = t[10] -- miss", function(n)
    local t = {0,1,2,3,4,5,6,7,8,9}
    local r = nil
    local tm = os.clock()
    for i = 1,n do
        r = t[10]; r = t[10]; r = t[10]; r = t[10]; r = t[10];
        r = t[10]; r = t[10]; r = t[10]; r = t[10]; r = t[10];
        r = t[10]; r = t[10]; r = t[10]; r = t[10]; r = t[10];
        r = t[10]; r = t[10]; r = t[10]; r = t[10]; r = t[10];
    end
    return os.clock() - tm, 20
end)

bench("TGETB", "r = t[100] -- miss", function(n)
    local t = {0,1,2,3,4,5,6,7,8,9}
    local r = nil
    local tm = os.clock()
    for i = 1,n do
        r = t[100]; r = t[100]; r = t[100]; r = t[100]; r = t[100];
        r = t[100]; r = t[100]; r = t[100]; r = t[100]; r = t[100];
        r = t[100]; r = t[100]; r = t[100]; r = t[100]; r = t[100];
        r = t[100]; r = t[100]; r = t[100]; r = t[100]; r = t[100];
    end
    return os.clock() - tm, 20
end)

------------------------------------------------------------------------------
-- TGETR
------------------------------------------------------------------------------

-- TODO: TGETR

------------------------------------------------------------------------------
-- TSETV
------------------------------------------------------------------------------

bench("TSETV", "t[x (1)] = y (0)", function(n)
    local t = {1,2,3,4,5}
    local x, y = 1, 0
    local tm = os.clock()
    for i = 1,n do
        t[x] = y; t[x] = y; t[x] = y; t[x] = y; t[x] = y;
        t[x] = y; t[x] = y; t[x] = y; t[x] = y; t[x] = y;
        t[x] = y; t[x] = y; t[x] = y; t[x] = y; t[x] = y;
        t[x] = y; t[x] = y; t[x] = y; t[x] = y; t[x] = y;
    end
    return os.clock() - tm, 20
end)

bench("TSETV", "t[x (\"key\")] = y (0)", function(n)
    local t = { key = 0 }
    local x, y = "key", 0
    local tm = os.clock()
    for i = 1,n do
        t[x] = y; t[x] = y; t[x] = y; t[x] = y; t[x] = y;
        t[x] = y; t[x] = y; t[x] = y; t[x] = y; t[x] = y;
        t[x] = y; t[x] = y; t[x] = y; t[x] = y; t[x] = y;
        t[x] = y; t[x] = y; t[x] = y; t[x] = y; t[x] = y;
    end
    return os.clock() - tm, 20
end)

bench("TSETV", "t[x (\"key\")] = y (\"hello\")", function(n)
    local t = { key = 0 }
    local x, y = "key", "hello"
    local tm = os.clock()
    for i = 1,n do
        t[x] = y; t[x] = y; t[x] = y; t[x] = y; t[x] = y;
        t[x] = y; t[x] = y; t[x] = y; t[x] = y; t[x] = y;
        t[x] = y; t[x] = y; t[x] = y; t[x] = y; t[x] = y;
        t[x] = y; t[x] = y; t[x] = y; t[x] = y; t[x] = y;
    end
    return os.clock() - tm, 20
end)

------------------------------------------------------------------------------
-- TSETS
------------------------------------------------------------------------------

bench("TSETS", "t[\"key\"] = y (1)", function(n)
    local t = { key = 0 }
    local y = 1
    local tm = os.clock()
    for i = 1,n do
        t["key"] = y; t["key"] = y; t["key"] = y; t["key"] = y; t["key"] = y;
        t["key"] = y; t["key"] = y; t["key"] = y; t["key"] = y; t["key"] = y;
        t["key"] = y; t["key"] = y; t["key"] = y; t["key"] = y; t["key"] = y;
        t["key"] = y; t["key"] = y; t["key"] = y; t["key"] = y; t["key"] = y;
    end
    return os.clock() - tm, 20
end)

bench("TSETS", "t[\"key\"] = y (\"hello\")", function(n)
    local t = { key = 0 }
    local y = "hello"
    local tm = os.clock()
    for i = 1,n do
        t["key"] = y; t["key"] = y; t["key"] = y; t["key"] = y; t["key"] = y;
        t["key"] = y; t["key"] = y; t["key"] = y; t["key"] = y; t["key"] = y;
        t["key"] = y; t["key"] = y; t["key"] = y; t["key"] = y; t["key"] = y;
        t["key"] = y; t["key"] = y; t["key"] = y; t["key"] = y; t["key"] = y;
    end
    return os.clock() - tm, 20
end)

------------------------------------------------------------------------------
-- TSETB
------------------------------------------------------------------------------

bench("TSETB", "t[1] = y (0)", function(n)
    local t = {1,2,3,4,5}
    local y = 0
    local tm = os.clock()
    for i = 1,n do
        t[1] = y; t[1] = y; t[1] = y; t[1] = y; t[1] = y;
        t[1] = y; t[1] = y; t[1] = y; t[1] = y; t[1] = y;
        t[1] = y; t[1] = y; t[1] = y; t[1] = y; t[1] = y;
        t[1] = y; t[1] = y; t[1] = y; t[1] = y; t[1] = y;
    end
    return os.clock() - tm, 20
end)

bench("TSETB", "t[1] = y (\"hello\")", function(n)
    local t = {1,2,3,4,5}
    local y = "hello"
    local tm = os.clock()
    for i = 1,n do
        t[1] = y; t[1] = y; t[1] = y; t[1] = y; t[1] = y;
        t[1] = y; t[1] = y; t[1] = y; t[1] = y; t[1] = y;
        t[1] = y; t[1] = y; t[1] = y; t[1] = y; t[1] = y;
        t[1] = y; t[1] = y; t[1] = y; t[1] = y; t[1] = y;
    end
    return os.clock() - tm, 20
end)

------------------------------------------------------------------------------
-- TSETR
------------------------------------------------------------------------------

-- TODO: TSETR

------------------------------------------------------------------------------
-- TSETM
------------------------------------------------------------------------------

-- TODO: TSETM

------------------------------------------------------------------------------
-- CALL
------------------------------------------------------------------------------

bench("CALL", "foo()", function(n)
    local function foo() end
    local tm = os.clock()
    for i = 1,n do
        foo(); foo(); foo(); foo(); foo();
        foo(); foo(); foo(); foo(); foo();
        foo(); foo(); foo(); foo(); foo();
        foo(); foo(); foo(); foo(); foo();
    end
    return os.clock() - tm, 20
end)

------------------------------------------------------------------------------
-- CALLT
------------------------------------------------------------------------------

bench("CALLT", "foo()", function(n)
    local function foo4() end
    local function foo3() return foo4() end
    local function foo2() return foo3() end
    local function foo1() return foo2() end
    local function foo0() return foo1() end
    local function foo()  return foo0() end
    local tm = os.clock()
    for i = 1,n do
        foo();
        foo();
        foo();
        foo();
    end
    return os.clock() - tm, 20
end)

------------------------------------------------------------------------------
-- VARG
------------------------------------------------------------------------------

-- TODO: VARG

------------------------------------------------------------------------------
-- RET0
------------------------------------------------------------------------------

bench("RET0", "function foo() end", function(n)
    local function foo() end
    local tm = os.clock()
    for i = 1,n do
        foo(); foo(); foo(); foo(); foo();
        foo(); foo(); foo(); foo(); foo();
        foo(); foo(); foo(); foo(); foo();
        foo(); foo(); foo(); foo(); foo();
    end
    return os.clock() - tm, 20
end)

------------------------------------------------------------------------------
-- RET1
------------------------------------------------------------------------------

bench("RET1", "function foo() return 0 end", function(n)
    local function foo() return 0 end
    local tm = os.clock()
    for i = 1,n do
        foo(); foo(); foo(); foo(); foo();
        foo(); foo(); foo(); foo(); foo();
        foo(); foo(); foo(); foo(); foo();
        foo(); foo(); foo(); foo(); foo();
    end
    return os.clock() - tm, 20
end)

------------------------------------------------------------------------------
-- RET
------------------------------------------------------------------------------

bench("RET", "function foo() return 0, 1 end", function(n)
    local function foo() return 0, 1 end
    local tm = os.clock()
    for i = 1,n do
        foo(); foo(); foo(); foo(); foo();
        foo(); foo(); foo(); foo(); foo();
        foo(); foo(); foo(); foo(); foo();
        foo(); foo(); foo(); foo(); foo();
    end
    return os.clock() - tm, 20
end)

bench("RET", "function foo() return 0, 1, 3, 4 end", function(n)
    local function foo() return 0, 1, 3, 4 end
    local tm = os.clock()
    for i = 1,n do
        foo(); foo(); foo(); foo(); foo();
        foo(); foo(); foo(); foo(); foo();
        foo(); foo(); foo(); foo(); foo();
        foo(); foo(); foo(); foo(); foo();
    end
    return os.clock() - tm, 20
end)

------------------------------------------------------------------------------
-- RETM
------------------------------------------------------------------------------

-- TODO: RETM

------------------------------------------------------------------------------
-- FORI
------------------------------------------------------------------------------

-- 0018 => KSHORT   6   1           << some overhead to setup a loop
-- 0019    KSHORT   7   0
-- 0020    KSHORT   8   1
-- 0021    FORI     6 => 0023       << always taken
-- 0022 => FORL     6 => 0022
-- 0023 => KSHORT   6   1
bench("FORI", "for i = 1,0 do end -- loop setup overhead", function(n)
    local tm = os.clock()
    local s, e = 1, 0
    for i = 1,n do
        for i = 1,0 do end; for i = 1,0 do end;
        for i = 1,0 do end; for i = 1,0 do end;
        for i = 1,0 do end
        for i = 1,0 do end; for i = 1,0 do end;
        for i = 1,0 do end; for i = 1,0 do end;
        for i = 1,0 do end
        for i = 1,0 do end; for i = 1,0 do end;
        for i = 1,0 do end; for i = 1,0 do end;
        for i = 1,0 do end
        for i = 1,0 do end; for i = 1,0 do end;
        for i = 1,0 do end; for i = 1,0 do end;
        for i = 1,0 do end
    end
    return os.clock() - tm, 20
end)

------------------------------------------------------------------------------
-- FORL
------------------------------------------------------------------------------

bench("FORL", "for i = 1,100 do end", function(n)
    local tm = os.clock()
    for i = 1,n do
        for i = 1,100 do end
    end
    return os.clock() - tm, 100
end)

------------------------------------------------------------------------------
-- ITERC
------------------------------------------------------------------------------

bench("ITERL", "for i in ipairs(t) do end", function(n)
    local t = {}
    for i = 1,100 do
        t[i] = i
    end
    local tm = os.clock()
    for i = 1,n do
        for i in ipairs(t) do end
    end
    return os.clock() - tm, 100
end)

------------------------------------------------------------------------------
-- ITERN
------------------------------------------------------------------------------

bench("ITERN", "for i,k in pairs(t) do end", function(n)
    local t = {}
    for i = 1,100 do
        t[i] = i
    end
    local tm = os.clock()
    for i = 1,n do
        for i,k in pairs(t) do end
    end
    return os.clock() - tm, 100
end)

------------------------------------------------------------------------------
-- LOOP
------------------------------------------------------------------------------

bench("LOOP", "while x <= y do x = x + 1 end", function(n)
    local tm = os.clock()
    for i = 1,n do
        local x = 1
        local y = 100
        while x <= y do x = x + 1 end
    end
    return os.clock() - tm, 100
end)

------------------------------------------------------------------------------
-- Base library
------------------------------------------------------------------------------

-- checks
bench_func_1("ff_assert", assert, true)
bench_func_1("ff_type", type, 0)

-- conversions
bench_func_1("ff_tonumber", tonumber, 123)
bench_func_1("ff_tonumber", tonumber, "123")
bench_func_1("ff_tostring", tostring, "123")
bench_func_1("ff_tostring", tostring, 123)

-- iterators
local t = {}
for i = 1,30 do
    t[#t+1] = i
end
bench_func_1("ff_next", next, t, "array")
bench_func_2("ff_next", next, t, 15)

local t = {}
for i = 1,99 do
    t["key"..i] = i
end
bench_func_1("ff_next", next, t, "map")
bench_func_2("ff_next", next, t, "key1")
bench_func_2("ff_next", next, t, "key33")
bench_func_2("ff_next", next, t, "key99")

bench_func_1("ff_pairs", pairs, t)
bench_func_1("ff_ipairs", ipairs, t)

-- catch errors
bench_func_1("ff_pcall", pcall, function() end)
bench_func_2("ff_pcall", pcall, function() end, 0)
bench_func_3("ff_pcall", pcall, function() end, 0, 0)
bench_func_4("ff_pcall", pcall, function() end, 0, 0, 0)

bench_func_2("ff_xpcall", xpcall, function() end, function() end)
bench_func_3("ff_xpcall", xpcall, function() end, function() end, 0)
bench_func_4("ff_xpcall", xpcall, function() end, function() end, 0, 0)

------------------------------------------------------------------------------
-- Math library
------------------------------------------------------------------------------

local math = require("math")
local x = 13.13
local y = 8

bench_func_1("ff_math_abs", math.abs, x)
bench_func_1("ff_math_sqrt", math.sqrt, x)
bench_func_1("ff_math_floor", math.floor, x)
bench_func_1("ff_math_ceil", math.ceil, x)
bench_func_1("ff_math_log", math.log, x)
bench_func_1("ff_math_log10", math.log10, x)
bench_func_1("ff_math_exp", math.exp, x)
bench_func_1("ff_math_sin", math.sin, x)
bench_func_1("ff_math_cos", math.cos, x)
bench_func_1("ff_math_tan", math.tan, x)
bench_func_1("ff_math_asin", math.asin, x)
bench_func_1("ff_math_acos", math.acos, x)
bench_func_1("ff_math_atan", math.atan, x)
bench_func_1("ff_math_sinh", math.sinh, x)
bench_func_1("ff_math_cosh", math.cosh, x)
bench_func_1("ff_math_tanh", math.tanh, x)
bench_func_1("ff_math_frexp", math.frexp, x)
bench_func_1("ff_math_modf", math.modf, x)

bench_func_2("ff_math_pow", math.pow, x, y)
bench_func_2("ff_math_atan2", math.atan2, x, y)
bench_func_2("ff_math_fmod", math.fmod, x, y)
bench_func_2("ff_math_ldexp", math.ldexp, x, y)
bench_func_2("ff_math_min", math.min, x, y)
bench_func_2("ff_math_max", math.max, x, y)

------------------------------------------------------------------------------
-- String library
------------------------------------------------------------------------------

bench_func_1("ff_string_byte", string.byte, "abcdefg")
bench_func_2("ff_string_byte", string.byte, "abcdefg", 1)
bench_func_2("ff_string_byte", string.byte, "abcdefg", 2)
bench_func_2("ff_string_byte", string.byte, "abcdefg", 3)
bench_func_2("ff_string_byte", string.byte, "abcdefg", 7)
bench_func_3("ff_string_byte", string.byte, "abcdefg", 1, 2)
bench_func_3("ff_string_byte", string.byte, "abcdefg", 1, 3)
bench_func_3("ff_string_byte", string.byte, "abcdefg", 1, 7)

bench_func_1("ff_string_char", string.char, 65)
bench_func_1("ff_string_char", string.char, 79)
bench_func_2("ff_string_char", string.char, 65, 82)
bench_func_3("ff_string_char", string.char, 65, 82, 99)

bench_func_2("ff_string_sub", string.sub, "foobar", 1)
bench_func_2("ff_string_sub", string.sub, "foobar", 3)
bench_func_3("ff_string_sub", string.sub, "foobar", 1, 3)
bench_func_3("ff_string_sub", string.sub, "foobar", 3, 5)

bench_func_1("ff_string_reverse", string.reverse, "abc")
bench_func_1("ff_string_reverse", string.reverse, "foobar")
bench_func_1("ff_string_reverse", string.reverse, "foobar123456")

bench_func_1("ff_string_lower", string.lower, "ABC")
bench_func_1("ff_string_lower", string.lower, "FOOBAR")
bench_func_1("ff_string_lower", string.lower, "FOOBAR123456")

bench_func_1("ff_string_upper", string.upper, "abc")
bench_func_1("ff_string_upper", string.upper, "foobar")
bench_func_1("ff_string_upper", string.upper, "foobar123456")

------------------------------------------------------------------------------
-- Bit library
------------------------------------------------------------------------------

local bit = require("bit")

bench_func_2("ff_bit_band", bit.band, 1, 1)
bench_func_3("ff_bit_band", bit.band, 1, 3, 7)
bench_func_4("ff_bit_band", bit.band, 1, 3, 7, 15)

bench_func_2("ff_bit_bor", bit.bor, 1, 1)
bench_func_3("ff_bit_bor", bit.bor, 1, 3, 7)
bench_func_4("ff_bit_bor", bit.bor, 1, 3, 7, 15)

bench_func_2("ff_bit_bxor", bit.bxor, 1, 1)
bench_func_3("ff_bit_bxor", bit.bxor, 1, 3, 7)
bench_func_4("ff_bit_bxor", bit.bxor, 1, 3, 7, 15)

bench_func_1("ff_bit_tobit", bit.tobit, 123)
bench_func_1("ff_bit_tobit", bit.tobit, 0xffffffff + 124)

bench_func_1("ff_bit_bswap", bit.bswap, 0x12345678)
bench_func_1("ff_bit_bnot", bit.bnot, 0)

bench_func_2("ff_bit_lshift", bit.lshift, 1, 8)
bench_func_2("ff_bit_rshift", bit.rshift, 0x100, 8)
bench_func_2("ff_bit_arshift", bit.arshift, -256, 8)
bench_func_2("ff_bit_rol", bit.rol, 0x12345678, 8)
bench_func_2("ff_bit_ror", bit.ror, 0x12345678, 8)

------------------------------------------------------------------------------
-- Coroutine library
------------------------------------------------------------------------------

local function co_test()
    local yield = coroutine.yield
    while true do
        yield(123)
    end
end

bench_func_1("ff_coroutine_resume", coroutine.resume, coroutine.create(co_test))
bench_func_0("ff_coroutine_wrap", coroutine.wrap(co_test))

------------------------------------------------------------------------------
-- END
------------------------------------------------------------------------------

local function is_enabled(name)
    if #filter == 0 then return true end
    local name = lower(name)
    for i,f in ipairs(filter) do
        if string.find(name, f) then
            return true
        end
    end
    return false
end

if list_benchmarks then
    write(format(" group                | description\n"))
    write(format("----------------------|-------------\n"))
    for i,t in ipairs(benches) do
        if is_enabled(t.name) then
            write(format(" %-20s | %s\n", t.name, t.desc))
        end
    end
    return 0
end

local baseline = {}

if load_baseline then
    f = io.open(load_baseline, "r")
    if f ~= nil then
        for line in f:lines() do
            local items = {}
            items[#items+1] = string.match(line, "[^\t]+")
            for chunk in string.gmatch(line, "\t[^\t]+", 1) do
                items[#items+1] = string.sub(chunk, 2)
            end
            local tm = tonumber(items[1])
            local iter = tonumber(items[2])
            local iter_ops = tonumber(items[3])
            local name = items[4]
            local desc = items[5]
            if baseline[name] == nil then
                baseline[name] = {}
            end
            baseline[name][desc] = { tm = tm, iter = iter, iter_ops = iter_ops }
        end
    else
        io.stderr:write(format("warning: failed to read baseline file \"%s\"\n\n", load_baseline))
    end
end

local output = nil
if save_baseline then
    output = io.open(save_baseline, "w")
    if output == nil then
        io.stderr:write("error: failed to create baseline file \"%s\"\n", save_baseline)
        return
    end
end

write(format(" frequency: %.1f\n", freq))
write(format("iterations: %d\n", n))
write(format("   repeats: %d\n", repeats))
for i,f in ipairs(filter) do
    write(format("    filter: %s\n", f))
end
write(format("\n"))
write(format("      c/i |    c/o | change | change | group                | description\n"))
write(format("----------|--------|--------|--------|----------------------|-------------\n"))
io.flush()

jit.off()

for i,t in ipairs(benches) do
    if is_enabled(t.name) then
        local tm, ops = nil, 1
        for i = 1,repeats do
            local t, o = t.func(n)
            if not tm or t < tm then
                tm = t
                ops = o
            end
        end
        local cycles = tm * 1e9 * freq
        local iter = cycles / n
        local iter_ops = iter / ops
        local b = baseline[t.name] and baseline[t.name][t.desc]
        local diff = 0
        write(format(" %8.1f | %6.1f", iter, iter_ops))
        if b ~= nil then
            local diff = iter_ops - b.iter_ops
            local p = (iter_ops / b.iter_ops) * 100 - 100
            if math.abs(p) >= 0.5 then
                write(format(" | %6.1f", diff))
            else
                write(format(" |       "))
            end
            if math.abs(p) >= 1.0 then
                write(format(" | %5.0f%%", p))
            else
                write(format(" |       "))
            end
        else
            write(format(" | ------ | ------"))
        end
        write(format(" | %-20s | %s\n", t.name, t.desc))
        if save_baseline then
            output:write(format("%f\t%f\t%f\t%s\t%s\n", tm, iter, iter_ops, t.name, t.desc))
        end
        io.flush()
    end
end
