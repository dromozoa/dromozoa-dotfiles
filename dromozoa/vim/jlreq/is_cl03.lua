return function (c)
  c = c + 0
  if c < 12316 then
    if c < 8211 then
      if c < 8209 then
        return c >= 8208
      else
        return false
      end
    else
      return c < 8212
    end
  else
    if c < 12448 then
      return c < 12317
    else
      return c < 12449
    end
  end
end
