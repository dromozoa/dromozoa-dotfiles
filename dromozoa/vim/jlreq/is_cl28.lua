return function (c)
  c = c + 0
  if c < 92 then
    if c < 41 then
      return c >= 40
    else
      return c >= 91
    end
  else
    if c < 12309 then
      return c >= 12308
    else
      return false
    end
  end
end
