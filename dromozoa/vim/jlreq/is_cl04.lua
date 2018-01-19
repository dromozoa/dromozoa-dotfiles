return function (c)
  c = c + 0
  if c < 8252 then
    if c < 63 then
      if c < 34 then
        return c >= 33
      else
        return false
      end
    else
      return c < 64
    end
  else
    if c < 8263 then
      return c < 8253
    else
      return c < 8266
    end
  end
end
