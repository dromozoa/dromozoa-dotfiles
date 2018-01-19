return function (c)
  c = c + 0
  if c < 46 then
    if c < 44 then
      if c < 33 then
        return c >= 32
      else
        return false
      end
    else
      return c < 45
    end
  else
    if c < 48 then
      return c < 47
    else
      return c < 58
    end
  end
end
