function [res] = histogram_clahe1(varargin)
%HISTOGRAM_CLAHE1 Contrast-limited Adaptive Histogram Equalization v. 1
% Usage: H = histogram_clahe1(I, numBins, windowSize, clipLevel)
 
  NBINS = 256;
  WINSIZE = [8 8];
  CLIPVAL = -1.0;
  if nargin == 1,
      I = varargin{1};
      numBins = NBINS;
      winSize = WINSIZE;
      clipLevel = CLIPVAL;
  elseif nargin == 2,
      I = varargin{1};
      numBins = varargin{2};
      winSize = WINSIZE;
      clipLevel = CLIPVAL;
  elseif nargin == 3, 
      I = varargin{1};
      numBins = varargin{2};
      winSize = varargin{3};
      clipLevel = CLIPVAL;
  else
      I = varargin{1};
      numBins = varargin{2};
      winSize = varargin{3};
      clipLevel = varargin{4};
  end
  
  if isempty(numBins),
      numBins = NBINS;
  end
  
  if isscalar(winSize),
      if winSize == -1,
        winSize = WINSIZE;
      else 
        winSize = [winSize winSize];
      end
  elseif isempty(winSize),
      winSize = WINSIZE;
  end
  
  if isstr(I),
      I = imread(I);
  end
  
  if size(I,3) > 1,
      I = rgb2gray(I);
  end
  [row,col] = size(I);
  selectedRange = [min(I(:)) max(I(:))];
  if clipLevel == -1.0,
      clipLevel = mean(histogram(I));
  end
  clipLevel
  numTileX = floor(row / winSize(1));
  numTileY = floor(col / winSize(2));
  
  if winSize(1)*winSize(2) > size(I,1) || winSize(1)*winSize(2) > size(I,2)
      error('Too big a tile!!');
  end

  range = double(max(I(:)) - min(I(:))) + 1;
  hgram = 1:range;
  hgram(:) = 0;
  winPixels = winSize(1) * winSize(2);
  stepSize = range / numBins;
  tHgram = 1:(numBins+1);
  
  r = 1:winSize(1);
  c = 1:winSize(2);
  
  %% Padding Image
  I2 = zeros(row + winPixels, col + winPixels);
  I2(1:row, 1:col) = I;
  I2(row+1:row+winPixels, 1:col) = I(row - winPixels+1 : row, 1:col);
  I2(1:row, col+1:col+winPixels) = I(1:row, col - winPixels+1 : col);
  I2(row+1:row+winPixels, col+1:col+winPixels) = ...
        I(row - winPixels+1: row, col - winPixels+1 : col);
    
  %% Process each tile
  for i = 0:numTileX
    for j = 0:numTileY
        
       histUL = histogram(I2(i*winSize(1)+r, j*winSize(2)+c),numBins, ...
           selectedRange(1),selectedRange(2),'clip',clipLevel);    
       histUL = cumsum(histUL);
       histDL = histogram(I2((i+1)*winSize(1)+r, j*winSize(2)+c),numBins,...
           selectedRange(1),selectedRange(2),'clip',clipLevel);   
       histDL = cumsum(histDL);
       histUR = histogram(I2(i*winSize(1)+r, (j+1)*winSize(2)+c),numBins,...
           selectedRange(1),selectedRange(2),'clip',clipLevel);   
       histUR = cumsum(histUR);
       histDR = histogram(I2((i+1)*winSize(1)+r, (j+1)*winSize(2)+c),numBins,...
           selectedRange(1),selectedRange(2),'clip',clipLevel);   
       histDR = cumsum(histDR);
    
       % Bilinear interpolation
       for y=1:winSize(1)
           for x=1:winSize(2)
              pixVal = floor(I2(i*winSize(1)+y, j*winSize(2)+x)/stepSize) + 1;
              fU = histUL(pixVal) * (winSize(1) - x) + ...
                   histUR(pixVal) * x;
              fD = histDL(pixVal) * (winSize(2) - x) + ...
                   histDR(pixVal) * x;
               
              I2(i*winSize(1)+y, j*winSize(2)+x) = (fU*(winSize(1)-y)+fD*y)/winPixels*255;
           end
       end
       
    end
  end
  
  res = I2(1:row,1:col);