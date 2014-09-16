function [varargout] = phasecorr(f, g, h, cutoff)
  
  if nargin < 2,
      error('Missing arguments');
  end
    
  if size(f,3) > 1,
      f = rgb2gray(f);
  end
  
  if size(g,3) > 1,
      g = rgb2gray(g);
  end
  
  if ~exist('h','var') || isempty(h),
      h = '';
  end
  
  if ~exist('cutoff','var') || isempty(cutoff),
      cutoff = 20;
  end

  if or(size(g,1) ~= size(f,1), size(g,2) ~= size(f,2)),
      f = imresize(f,size(g),'bicubic');
  end

  [nx,ny] = size(f);
  ff = double(f) ;
  gg = double(g) ;
  
 G = fft2(double(gg),2*nx-1,2*ny-1); G = fftshift(G);
 F = conj(fft2(double(ff),2*nx-1,2*ny-1)); F = fftshift(F);
  
%   G = fft2(double(g)); G = fftshift(G);
%   F = conj(fft2(double(f))); F = fftshift(F);
 
  filter = ones(2*nx-1,2*ny-1);
  
  if isequal(h,'butter'),
      filter = ones(2*nx-1,2*ny-1);
      n = 2;
      for i=1:(2*nx-1)
          for j=1:(2*ny-1)
              dist = ((i-nx-1)^2 + (j-ny-1)^2)^0.5;
              filter(i,j) = 1/(1 + (dist/cutoff)^(2*n));
          end
      end
  elseif isequal(h,'gauss'),
      filter = ones(2*nx-1,2*ny-1);
      for i=1:(2*nx-1)
          for j=1:(2*ny-1)
              dist = ((i-nx-1)^2 + (j-ny-1)^2)^0.5;
              filter(i,j) = exp(-dist*dist / (2*cutoff*cutoff));
          end
      end
  elseif isequal(h,'box'),
      filter = zeros(2*nx-1,2*ny-1);
      for i=1:(2*nx-1)
          for j=1:(2*ny-1)
              dist = ((i-nx-1)^2 + (j-ny-1)^2)^0.5;
              if dist <= cutoff,
                  filter(i,j) = 1;
              end
          end
      end
  end
  
  P = G.*F / (abs(G.*F));
  
%   filtP = P.*filter;
  filtP = P;

  filtP = ifftshift(filtP);
  p = ifft2(filtP,2*nx-1,2*ny-1);
%   p = ifft2(filtP);
  p = abs(p(1:nx,1:ny));
  varargout{1} = (p);
  
  [~,idx] = max(max(P));
  [row,col] = ind2sub(size(P),idx);

  if nargout > 1,
    varargout{2} = row;
    varargout{3} = col;
    varargout{4} = filter;
  end