return function (c)
  c = c + 0
  if c < 94 then
    if c < 42 then
      return c >= 41
    else
      return c >= 93
    end
  else
    if c < 12310 then
      return c >= 12309
    else
      return false
    end
  end
end
