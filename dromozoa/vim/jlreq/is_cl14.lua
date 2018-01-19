return function (c)
  c = c + 0
  if c < 12289 then
    return c >= 12288
  else
    return false
  end
end
