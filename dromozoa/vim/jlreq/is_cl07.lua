return function (c)
  c = c + 0
  if c < 12289 then
    if c < 45 then
      return c >= 44
    else
      return false
    end
  else
    return c < 12290
  end
end
