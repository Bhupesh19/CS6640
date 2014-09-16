%% Phase Correlation

I1 = imread('0001.001.png');
I2 = imread('0001.004.png');

% I1 = rand(100,100)*255;
% I2 = zeros(100,100);
% I2(11:100,22:100) = I1(1:90,1:79);

[P,row,col,F] = phasecorr(I1,I2,'butter',5);
% [P,I1,I2,F] = phasecorr(I1,I2,'gauss');
% [P,I1,I2,F] = phasecorr(I1,I2,'box',20);

figure(1); 
subplot(221); imshow(F); 
subplot(222); imshow(I1,[]);
subplot(223); imshow(I2,[]);
subplot(224); imshow(P,[]);
figure(2); mesh(P); shading interp; axis tight;

%% Peak Finding
% [peak,idx] = max(max(P));
% [row,col] = ind2sub(size(P),idx);
%disp(sprintf('Peak at x = %d, y = %d, val = %f\n',row,col,P(x,y)));
% I = zeros(size(P));
% I(row:row+5,col:col+5) = 1;
% imshow(I,[]);

maxP = max(P(:)); minP = min(P(:));
P = (P - minP) / (maxP - minP);
[pH,X] = imhist(P);
cumpH = cumsum(pH*numel(P)/sum(pH));
maxm = max(cumpH(:));
idx = find(cumpH > round(0.95*maxm), 1);
thresh = X(idx);

binP = zeros(size(P));
binP(P > thresh) = 1;

[L,N] = ConnectedComponent(binP, 1, 8);
figure, imagesc(L);

%% Mosaic Building

filenames = cell(1,4);
filenames(1) = {'0001.000.png'};
filenames(2) = {'0001.001.png'};
filenames(3) = {'0001.002.png'};
filenames(4) = {'0001.004.png'};

[res] = buildMosaic(filenames, 1);
figure, imshow(res,[]); 