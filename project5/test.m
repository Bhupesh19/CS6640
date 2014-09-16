% A = imread('surface_mount.tif');
A  = imread('cameraman.tif');
% A = imread('coins.png');
% A = zeros(50,50); A(20:40, 20:40) = 1;

if size(A,3) > 1, 
    A = rgb2gray(A);
end

if ~isequal(class(A),'double'),
    A = im2double(A);
end

%% Preprocessing & Edge Detection
disp('Preprocessing & Edge Detection');
[m,n] = size(A);
sigma = 2;
w = 3;
sigma_i = 3;
sigma_d = 1;
method='LOG';
thresh = []; %0.1039;

B = A;
iter = 2;
for i=1:iter
 B = bilfilt2(B,w,sigma_i,sigma_d);
%  B = anisodiff2D(B,15,1/7,30,2);
%  B = medfilt2(A,[w w]);
end

% Laplacian of Gaussian
switch method
    case 'LOG',
        [x,y] = meshgrid(-w:w,-w:w);
        op = -(1 - (x.^2+y.^2)/(2*sigma^2)) .* ...
            exp(-(x.^2+y.^2)/(2*sigma^2)) .* 1/(pi * sigma^4);
        % Normalize filter
        op = op - sum(op(:)) / (numel(op));
      
        % Apply filter (used matlab code)
        B = imfilter(B,op,'replicate');
        
        e = zeroCross(B,thresh);
    case 'CANNY',
        % Edge in X-dir
        mask_x = [-1 0 1; -2 0 2; -1 0 1];
        Bx = imfilter(B,mask_x, 'replicate');
        ex = zeroCross(Bx,thresh);
        % Edge in Y-dir
        mask_y = [-1 -2 -1; 0 0 0; 1 2 1];
        By = imfilter(B,mask_y,'replicate');
        ey = zeroCross(By,thresh);
        
        % Edge magnitude
%         e = sqrt(Bx.^2 + By.^2);
        e = sqrt(ex.^2 + ey.^2);
    otherwise
        disp('Not implemented');
        op = eye(w);
end

clf;
subplot(131); imshow(A,[]);
subplot(132); imshow(B,[]);
subplot(133); imshow(e,[]);
imwrite(A,'results/original.png','png');
imwrite(B,['results/filtered_iter', num2str(iter),'.png'],'png');
imwrite(e,'results/edgeImage.png','png');
title(sprintf('Method = %s,Iteration:%d',method,iter));

%% Hysteresis thresholding
up = 0.9*max(e(:));
low = min(e(:)) + 0.4*(max(e(:)) - min(e(:)));
bw = hysthresh(e,low,up);
imwrite(bw,'results/edgeImage_1.png','png');
bw = e; %edge(B,'canny');

%% Line Detection
disp('Line Detection');
theta=-90:1:89;
H = myHoughLines(bw,1,theta,[],30);

%% Circle Detection
disp('Circle Detection');
rad = 35;
[Y,X,H] = myHoughCircle(bw,rad,rad*pi/2.5);
figure(1); 
imshow(bw,[]);
imshow(A,[]); hold on;
nseg = 50;
theta = 0 : (2*pi/nseg) : 2*pi;
for i=1:length(Y)
   px = rad*cos(theta)+X(i);  
   py = rad*sin(theta)+Y(i);
   plot(px,py,'r');
end
figure(3);
imshow(H,[]);