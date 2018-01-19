return function (c)
  c = c + 0
  if c < 12290 then
    if c < 47 then
      return c >= 46
    else
      return false
    end
  else
    return c < 12291
  end
end
