function [ Y, X, varargout  ] = myHoughCircle( Bw, rad, varargin )

  [m,n] = size(Bw);

  if nargin < 3, 
      thresh = 5;
  else
      thresh = varargin{1};
  end
  if nargin < 4,
      region = [1, 1, m, n];
  else
      region = varargin{2};
  end
  
  lowThresh = 5;
  % Accumulate
  H = zeros(m,n);
  minx = region(1); maxx = minx + region(3) - 1;
  miny = region(2); maxy = miny + region(4) - 1;
  [r, c] = find(Bw);
  
  for i=1:length(r)
      centerx = c(i); 
      centery = r(i);
      
      xleft = centerx - rad; xright = centerx + rad;
      yleft = centery - rad; yright = centery + rad;
      if (xleft < minx || xright > maxx || yleft < miny || yright > maxy)
          continue;
      end
      if yright <= m && yleft >= 1 && xright <= n && xleft >= 1,
          x = 1;
          y = rad;
          d = 1.25 - rad;
          H(yright, centerx) = H(yright, centerx) + 1;
          H(yleft, centerx)  = H(yleft, centerx) + 1;
          H(centery, xleft)  = H(centery, xleft) + 1;
          H(centery, xright) = H(centery, xright) + 1;
          
          % Traverse over the circle and increase accumulator for each
          % point on the circle.
          while y > x,
              x1l = centerx-x; x1r = centerx+x;
              y1l = centery-y; y1r = centery+y;
              y2l = centery-x; y2r = centery+x;
              x2l = centerx-y; x2r = centerx+y;
              H(y1l,x1l) = H(y1l,x1l)+1;
              H(y1r,x1l) = H(y1r,x1l)+1;
              H(y1l,x1r) = H(y1l,x1r)+1;
              H(y1r,x1r) = H(y1r,x1r)+1;
              H(y2l,x2l) = H(y2l,x2l)+1;
              H(y2l,x2r) = H(y2l,x2r)+1;
              H(y2r,x2l) = H(y2r,x2l)+1;
              H(y2r,x2r) = H(y2r,x2r)+1;
              
              if d < 0,
                  d = d + 2*x;
                  x = x+1;
              else
                  d = d + (x-y)*2;
                  x = x+1;
                  y = y-1;
              end
          end
          
          if x==y, % Unit circle
              x1l = centerx-x; x1r = centerx+x;
              y1l = centery-y; y1r = centery+y;
              H(y1l,x1l) = H(y1l,x1l) + 1;
              H(y1l,x1r) = H(y1l,x1r) + 1;
              H(y1r,x1l) = H(y1r,x1l) + 1;
              H(y1r,x1r) = H(y1r,x1r) + 1;
          end
      end
      
  end
  
  % Find peaks
  Y = []; X = [];
  [~,K] = sort(H(:),'descend');
  [y,x] = ind2sub(size(H), K);
  sz = length(x);
  y = y(1:sz);
  x = x(1:sz);
  HH = H - thresh;
%   ind = H < lowThresh;
%   HH(ind) = -1;
  for i=1:length(x)
      if HH(y(i),x(i)) >= 0,
          Y = [Y; y(i)];
          X = [X; x(i)];
      end
  end
  
  if nargout > 2,
      varargout{1} = H;
  end