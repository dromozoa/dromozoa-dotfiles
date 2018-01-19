return function (c)
  c = c + 0
  if c < 957 then
    if c < 53 then
      if c < 42 then
        if c < 33 then
          return c >= 32
        else
          return c >= 40
        end
      else
        if c < 48 then
          return c >= 47
        else
          return c >= 49
        end
      end
    else
      if c < 123 then
        if c < 91 then
          return c >= 65
        else
          return c >= 97
        end
      else
        if c < 938 then
          return c >= 937
        else
          return c >= 956
        end
      end
    end
  else
    if c < 8722 then
      if c < 8491 then
        if c < 8488 then
          return c >= 8487
        else
          return false
        end
      else
        return c < 8492
      end
    else
      if c < 12539 then
        return c < 8723
      else
        return c < 12540
      end
    end
  end
end
