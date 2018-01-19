return function (c)
  c = c + 0
  if c < 12298 then
    if c < 8216 then
      if c < 123 then
        if c < 91 then
          if c < 41 then
            return c >= 40
          else
            return false
          end
        else
          return c < 92
        end
      else
        if c < 171 then
          return c < 124
        else
          return c < 172
        end
      end
    else
      if c < 10629 then
        if c < 8220 then
          return c < 8217
        else
          return c < 8221
        end
      else
        if c < 12296 then
          return c < 10630
        else
          return c < 12297
        end
      end
    end
  else
    if c < 12308 then
      if c < 12302 then
        if c < 12300 then
          return c < 12299
        else
          return c < 12301
        end
      else
        if c < 12304 then
          return c < 12303
        else
          return c < 12305
        end
      end
    else
      if c < 12312 then
        if c < 12310 then
          return c < 12309
        else
          return c < 12311
        end
      else
        if c < 12317 then
          return c < 12313
        else
          return c < 12318
        end
      end
    end
  end
end
