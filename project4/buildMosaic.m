function [ res ] = buildMosaic( filenames, threshPeaks)
% filenames : cell array of filenames
% threshPeaks : threshold for phasecorr 
% Reference : http://www.mathworks.com/matlabcentral/fileexchange/19731-fourier-mellin-image-registration
 n = size(filenames);
 im = cell(1,n);
 
 for i=1:n
     I = imread(filenames{i});
     
     if size(I,3) > 1,
         I = rgb2gray(I);
     end
     im{i} = I;
 end
 
 adj = zeros(n,n);
 off = cell(n,n);
 
 for i=1:n
     for j=1:n
         I = im{i};
         J = im{j};
         
         [P,x,y] = phasecorr(I,J,threshPeaks);
         
         if ~isempty(x) && ~isempty(y),
             adj(i,j) = 1;
             off{i,j} = [x,y];
        end
     end
 end
 
 % Array to check if im{i} has been positioned on canvas
 ok = zeros(1,n);
  % Canvas
 res = im{1};
 % Location of im{i} on canvas
 loc = cell(1,n);
 loc{1} = [1 1]; % Place 1st image 
 ok(1) = 1;
 iter = 2; % Start from 2
 
 while(~all(ok))
     % If current image is not positioned, place it
     if (~ok(iter)),
         a=-1;
         % Find images on canvas with which it aligns
         for k=1:n
            if(adj(k,iter) && ok(k)),
              a=i;
              break;
            end
         end
         % No suitable match !! try with different image ..
         if (a==-1),
             a = mod(iter,n)+1;
             continue;
         end
         
         g=res; % mosaic
         f = im{iter}; % current image
         offsets = off{a,iter}; % peak
         % Location of im{a} on canvas
         cx = loc{a}(1)-1; 
         cy = loc{a}(2)-1;
         % shift needed to get im{iter} on canvas
         x=offsets{1}+cx;
         y=offsets{2}+cy;
         
         [r1,c1] = size(f);
         [r2,c2] = size(g);
         
         % Width of canvas
         if(x<= 0),
             m=r2+abs(x);
         else
             m=max(r2,r1+x);
         end
         
         % Height of canvas
         if(y<=0),
            n=abs(y)+c2;
         else
             n=max(c2,c1+y);
         end
             
         % Canvas : blank
         res = uint8(zeros(m,n));    
         
         % The four cases mentioned in the problem statement to resolve
         % ambiguity
         if (x > 0 && y > 0),
             res(1:r2,1:c2) = g;
             res(x+1:r1+x, y+1:c1+y) = f;
             loc{iter} = [x+1, y+1];
             sx = 1; sy = 1;
         elseif( x > 0 && y <= 0),
             res(1:r2, abs(y-1):c2+abs(y-1)-1) = g;
             res(x+1:r1+x, 1:c1) = f;
             loc{iter} = [x+1 1];
             sx = 1; sy = abs(y-1);
         elseif(x <= 0 && y > 0),
             res(abs(x-1):r2+abs(x-1)-1, 1:c2) = g;
             res(1:r1, y+1:c1+y) = f;
             loc{iter} = [1 y+1];
             sx = abs(x-1); sy = 1;
         else
             res(abs(x-1)+r1+abs(x-1)-1, abs(y-1):c2+abs(y-1)-1) = g;
             res(1:r1, 1:c1) = f;
             loc{iter} = [1 1];
             sx = 1; sy = abs(y-1);
         end
        
         % Update canvas loc
         for i=1:n
             if(ok(i)),
                 curx = loc{i}(1);
                 cury = loc{i}(2);
                 
                 loc{i} = [curx+sx-1 cury+sy-1];
             end
         end
         
         ok(iter) = true; % Current image is placed
         iter = mod(iter+1,6); % Move on.
     end
 end
     
end