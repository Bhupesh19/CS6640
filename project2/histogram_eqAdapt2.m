function [res] = histogram_eqAdapt2(varargin)
%HISTOGRAM_EQADAPT2 Adaptive Histogram Equalization v. 2
% Usage: H = histogram_eqAdapt2(I, numBins, windowSize)  

  NBINS = 256;
  WINSIZE = [8 8];
  if nargin == 1,
      I = varargin{1};
      numBins = NBINS;
      winSize = WINSIZE;
  elseif nargin == 2,
      I = varargin{1};
      numBins = varargin{2};
      winSize = WINSIZE;
  else 
      I = varargin{1};
      numBins = varargin{2};
      winSize = varargin{3};
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
  end

  if isstr(I),
      I = imread(I);
  end
  
  if size(I,3) > 1,
      I = rgb2gray(I);
  end
  [row,col] = size(I);
  numTileX = floor(row / winSize(1));
  numTileY = floor(col / winSize(2));
  
  range = double(max(I(:)) - min(I(:))) + 1;
  hgram = 1:range;
  hgram(:) = 0;
  winPixels = winSize(1) * winSize(2);
  stepSize = range / numBins;
  tHgram = 1:(numBins+1);
  
  %% Padding Image
  I2 = zeros(row + winSize(1), col + winSize(2));
  I2(1:row, 1:col) = I;
  I2(row+1:row+winSize(1), 1:col) = I(row - winSize(1)+1 : row, 1:col);
  I2(1:row, col+1:col+winSize(2)) = I(1:row, col - winSize(2)+1 : col);
  I2(row+1:row+winSize(1), col+1:col+winSize(2)) = ...
        I(row - winSize(1)+1: row, col - winSize(2)+1 : col);
    
  %% Process each tile
  for i = 0:numTileX
      for j = 0:numTileY
        
          maxPixWin = intmin;
          minPixWin = -intmin;
          for y = 1:winSize(1)
              for x = 1:winSize(2)
                  hgram(I2(i*winSize(1)+y, j*winSize(2)+x) + 1) = ...
                      hgram(I2(i*winSize(1)+y, j*winSize(2)+x) + 1) + 1;
                  
                  ind = I2(i*winSize(1)+y, j*winSize(2)+x) + 1;
                  if ind > maxPixWin, 
                      maxPixWin = ind;
                  end
                  if ind < minPixWin,
                      minPixWin = ind;
                  end
              end
          end
          
          tHgram(:) = 0;
          for r = 1:range
              tHgram( ceil(r / stepSize) ) = tHgram( ceil(r / stepSize)) + hgram(r)*(range / winPixels);
          end
          
          % Normalize the histogram values within a window.
          tHgram = cumsum(tHgram);
          tHgram = (tHgram * double(maxPixWin - minPixWin)) + double(minPixWin);
          
          for y = 1:winSize(1)
              for x = 1:winSize(2)
                  I2(i*winSize(1)+y, j*winSize(2)+x) = tHgram( floor(I2(i*winSize(1)+y, j*winSize(2)+x) / stepSize) + 1);
              end
          end
      end
  end
  
  res = I2(1:row,1:col);