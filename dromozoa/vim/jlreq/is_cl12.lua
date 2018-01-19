return function (c)
  c = c + 0
  if c < 8364 then
    if c < 164 then
      if c < 37 then
        return c >= 35
      else
        return c >= 163
      end
    else
      if c < 166 then
        return c >= 165
      else
        return false
      end
    end
  else
    if c < 8470 then
      return c < 8365
    else
      return c < 8471
    end
  end
end
