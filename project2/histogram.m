function [out,n] = histogram(I, varargin)
    
  if nargin < 2,
      n = 256;
  else
      n = varargin{1};
  end
    
  if nargin < 4,
      minm = min(I(:)); maxm = max(I(:));
  else
      minm = fix(varargin{2}); maxm = fix(varargin{3});
  end
  
  % CLAHE
  clipHgram = false;
  clipLevel = 0;
  if nargin == 6,
      clipHgram = strcmp(varargin{4},'clip');
      clipLevel = varargin{5};
  end
 
  if ~isa(minm,'double')
      minm = double(minm);
  end
  
  if ~isa(maxm,'double')
      maxm = double(maxm);
  end
  
  x = round(linspace(minm, maxm, n));
  out = zeros(1,numel(x));
  
  [row,col] = size(I);
  for r=1:row
      for c=1:col
          ind = find(x == I(r,c));
          if ~isempty(ind),
            out(ind) = out(ind) + 1;
          end
      end
  end
  
%    out = (out / maxm ) * size(I,1);
%   out = out * (numel(I)/sum(out));
  
  if clipHgram,
  
    % total numbe of pixels overflowing clip level in each bin
    totalExtra = sum(max(out - clipLevel,0));
    
    % clip the histogram and redistribute excess pixels in each bin
    avgBinIncr = floor(totalExtra/n);
    upperLimit = clipLevel - avgBinIncr; % bins larger than this will be set
                                         % to clip level
    
   % idea taken from adapthisteq.m
    for i = 1:n
       if out(i) > clipLevel,
           out(i) = clipLevel;
       else
          if out(i) > upperLimit,
            totalExtra = totalExtra - (clipLevel - out(i));
            out(i) = clipLevel;
          else
            totalExtra = totalExtra - avgBinIncr;
            out(i) = out(i) + avgBinIncr;
          end
       end
    end
    
%     clipLevel
    i = 1;
    while(totalExtra ~= 0)
        steps = max(floor(n / totalExtra),1);
        for m=i:steps:n
            if out(m) < clipLevel,
                out(m) = out(m) + 1;
                totalExtra = totalExtra - 1;
                if totalExtra == 0,
                    break;
                end
            end
        end
        
        i=i+1;
        if i > n,
            i = 1;
        end
    end
    
  end

  out = out * ( numel(I) /  sum(out) );
%   figure;  bar(x,out); 
%   title(sprintf('Histogram. Bins: %d',n)); axis tight;
