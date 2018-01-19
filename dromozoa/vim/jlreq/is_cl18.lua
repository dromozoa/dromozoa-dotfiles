return function (c)
  c = c + 0
  if c < 247 then
    if c < 178 then
      if c < 44 then
        return c >= 43
      else
        return c >= 177
      end
    else
      if c < 216 then
        return c >= 215
      else
        return false
      end
    end
  else
    if c < 8722 then
      return c < 248
    else
      return c < 8724
    end
  end
end
