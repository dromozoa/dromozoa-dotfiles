return function (c)
  c = c + 0
  if c < 8231 then
    if c < 8213 then
      return c >= 8212
    else
      return c >= 8229
    end
  else
    if c < 12342 then
      return c >= 12339
    else
      return false
    end
  end
end
