function res = isValid( row, col, width, height )
 
  res = false;
  if row > 0 && row < width && col > 0 && col < height,
      res = true;
  end    
end

