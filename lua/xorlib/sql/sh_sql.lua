xorlib.Dependency("xorlib/assert", "sh_assert.lua") -- x.Assert
xorlib.Dependency("xorlib/console", "sh_print.lua") -- x.Error

local select        = select
local next          = next
local SQLStr        = SQLStr
local sql_Query     = sql.Query
local string_format = string_format

function x.QuerySQLString(query, ...)
    local args = { ... }
    local argc = #args
    local argi = 1

    query = query:gsub("%?", function()
        x.Assert(argi <= argc, "Not enough arguments in query")
        local safeStr = SQLStr(args[argi])

        argi = argi + 1
        return safeStr
    end)

    return query
end

function x.QuerySQL(query, ...)
    local parsedQuery = x.QuerySQLString(query, ...)
    local output      = sql_Query(parsedQuery)

    if output == false then
        x.Error("Error while executing SQL\n" ..
                "Arg Count: %d\n" ..
                "Query: %s\n" ..
                "Parsed query: %s\n" ..
                "Error: %s",
                select("#", ...),
                query,
                parsedQuery,
                sql.LastError())
    end

    return output
end

function x.QuerySQLAll(query, ...)
    return x.QuerySQL(query, ...) or {}
end

function x.QuerySQLFirst(query, ...)
    local output = x.QuerySQL(query .. " LIMIT 1", ...)

    return output and output[1] or nil
end

function x.QuerySQLValue(table, column, condition, ...)
    local output = x.QuerySQLFirst(
        string_format("SELECT %s FROM ? WHERE %s", column, condition),
        table,
        ...
    )

    return output and output[column] or nil
end

function x.SQLHasRow(table, condition, ...)
    local output = x.QuerySQL(
        string_format("SELECT EXISTS(SELECT 1 FROM ? WHERE %s LIMIT 1)", condition),
        table,
        ...
    )[1]

    return output[next(output)] == "1"
end
