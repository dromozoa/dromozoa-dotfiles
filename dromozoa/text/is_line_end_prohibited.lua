---@param c integer
---@return boolean
return function (c)
  c = c + 0
  if c < 12300 then
    if c < 8220 then
      if c < 171 then
        if c < 92 then
          if c < 41 then
            return c >= 40
          else
            return c >= 91
          end
        else
          if c < 124 then
            return c >= 123
          else
            return false
          end
        end
      else
        if c < 8216 then
          return c < 172
        else
          return c < 8217
        end
      end
    else
      if c < 12296 then
        if c < 10629 then
          return c < 8221
        else
          return c < 10630
        end
      else
        if c < 12298 then
          return c < 12297
        else
          return c < 12299
        end
      end
    end
  else
    if c < 12310 then
      if c < 12304 then
        if c < 12302 then
          return c < 12301
        else
          return c < 12303
        end
      else
        if c < 12308 then
          return c < 12305
        else
          return c < 12309
        end
      end
    else
      if c < 12317 then
        if c < 12312 then
          return c < 12311
        else
          return c < 12313
        end
      else
        if c < 65288 then
          return c < 12318
        else
          return c < 65289
        end
      end
    end
  end
end
