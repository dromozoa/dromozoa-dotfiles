return function (c)
  c = c + 0
  if c < 12539 then
    if c < 60 then
      return c >= 58
    else
      return false
    end
  else
    return c < 12540
  end
end
