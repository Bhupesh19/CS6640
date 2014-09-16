function [w] = myhamming(L)
%w = hamming(L) returns an L-point symmetric Hamming window 
% in the column vector w. L should be a positive integer. The coefficients of a Hamming window are computed from the following equation.

   if nargin == 0,
      error('Missing arguments. Input L: number of points in Hamming window');
   end
   
   % Make vector
   if size(L,2) > 1,
       L = L(:);
   end

   w = (.54 - .46*cos(2*pi*(0:L-1)'/(L-1))).';
   
   % Repeat values if length of L > 1,
   if length(L) > 1,
       ww = w;
       for j=2:length(L)
           w(j,:) = ww;
       end
   end