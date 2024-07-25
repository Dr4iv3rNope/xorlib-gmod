function x.AddGridNumber(num, amount)
    if num < 0 then
        num = num - amount
    else
        num = num + amount
    end

    return num
end

function x.SubGridNumber(num, amount)
    return x.AddGridNumber(num, -amount)
end
