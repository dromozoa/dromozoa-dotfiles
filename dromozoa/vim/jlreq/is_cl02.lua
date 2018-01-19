return function (c)
  c = c + 0
  if c < 12299 then
    if c < 8217 then
      if c < 125 then
        if c < 93 then
          if c < 42 then
            return c >= 41
          else
            return false
          end
        else
          return c < 94
        end
      else
        if c < 187 then
          return c < 126
        else
          return c < 188
        end
      end
    else
      if c < 10630 then
        if c < 8221 then
          return c < 8218
        else
          return c < 8222
        end
      else
        if c < 12297 then
          return c < 10631
        else
          return c < 12298
        end
      end
    end
  else
    if c < 12309 then
      if c < 12303 then
        if c < 12301 then
          return c < 12300
        else
          return c < 12302
        end
      else
        if c < 12305 then
          return c < 12304
        else
          return c < 12306
        end
      end
    else
      if c < 12313 then
        if c < 12311 then
          return c < 12310
        else
          return c < 12312
        end
      else
        if c < 12319 then
          return c < 12314
        else
          return c < 12320
        end
      end
    end
  end
end
