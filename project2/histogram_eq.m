function [res,T] = histogram_eq(I,varargin)
%HISTOGRAM_EQ Histogram Equalization v. 1
% Usage: H = histogram_eq(I, numBins, minPixVal, maxPixVal) 

  MAXB = 64;
  
  % Can input filenames too.
  if isstr(I),
      I = imread(I);
  end
  
  % work only on grayscale double images.
  if size(I,3) > 1,
      I = rgb2gray(I(:,:,1:3));
  end
  
  if nargin == 1,
      n = MAXB;
      minm = min(I(:));
      maxm = max(I(:));
  elseif nargin < 4,
      n = varargin{1};
      minm = min(I(:));
      maxm = max(I(:));
  else 
      n = varargin{1}; 
      minm = varargin{2};
      maxm = varargin{3};
  end
  
% H = histogram(I,n,minm,maxm);
H = ones(1,n) * (numel(I) / n);
H = H * (numel(I) / sum(H));
  
%% Compute Cumulative Histogram

imgH = histogram(I,maxm-minm+1);
cumH = cumsum(imgH);

%% Compute Transformation To Intensity Image

cumDist = cumsum(H*numel(I)/sum(H));
m = n; n = maxm-minm+1;
tol = ones(m,1)*min([imgH(1:n-1)  0 ; 0 imgH(2:n)])/2;
err = (cumDist(:)*ones(1,n)-ones(m,1)*cumH(:)') + tol;
ind = find( err < -numel(I)*sqrt(eps));
if ~isempty(ind),
    err(ind) = numel(I) * ones(size(ind));
end
[~,T] = min(err);
T = (T-1)/(m-1);


%% Transform I using T

res = uint8(zeros(size(I)));
[row,col] = size(I);

sc = uint8(length(T)/255);

for r = 1:row
    for c = 1:col
        ind = uint8(I(r,c)*sc + 0.5);
        res(r,c) = uint8(255*T(ind) + 0.5);
    end
end

disp(sprintf('%d bins used',m));
% figure;
figure(1); imshow(I,[]); title('Original Image');
figure(2); imshow(res,[]); title('Transformed Image');
figure(3); plot(T); axis tight; 