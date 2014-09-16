function B = bilfilt2(I,w,sigma_i,sigma_d)

   if size(I,3) > 1,
       I = rgb2gray(I);
   end

   % Compute Gaussian distance weights
   [X,Y] = meshgrid(-w:w,-w:w);
   g = exp(-(X.^2+Y.^2)/(2*sigma_d*sigma_d));
   
   [m,n] = size(I);
   B = zeros(m,n);
   
   for r=1:m
       for c=1:n
           
           minr = max(r-w,1);
           maxr = min(m,r+w);
           minc = max(c-w,1);
           maxc = min(n,c+w);
           A = I(minr:maxr, minc:maxc);
           
           % Intensity weights  -- f(I(x_i) - I(x))
           F = exp(-(A-I(r,c)).^2 / (2*sigma_i*sigma_i));
           
           % Distance -- g(x_i - x)
           G = F .* g((minr:maxr)-r+w+1,(minc:maxc)-c+w+1); 
           B(r,c) = sum(G(:) .* A(:))/sum(G(:));
       end
   end
end