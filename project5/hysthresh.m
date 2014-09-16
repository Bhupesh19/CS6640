function [bw] = hysthresh(e, lowThresh, upThresh)

  if upThresh < lowThresh,
      temp = lowThresh;
      lowThresh = upThresh;
      upThresh = temp;
  end
   
  a = e > lowThresh;
  [r,c] = find(e > upThresh);
  
  bw = bwselect(a, r, c, 8);
end