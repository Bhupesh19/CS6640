close all;
clear all;

histo = 0;
conn_comp = 0;
top_denoise = 1;
motion_detection = 0;

%% Build Histogram 

if histo == 1,
    disp('Building histogram');
    I = imread('turkeys.tif');
    histogram(I, 256, 0, 255);
    clear I;
    disp('---------------------------------');
end

%% Flood fill

if 0,
    disp('Flood fill');

    % Test image
    % c = 0;
    % r = 4;
    % lims = [floor(c - 1.2*r) ceil(c + 1.2*r)];
    % [x,y] = meshgrid(lims(1):.5:lims(2));
    % img = sqrt(x.^2 + y.^2) <= r;
    % img(6:8,6:8) = 0;
    % figure, subplot(121); imagesc(img);
    % img = floodfill_It(6,6,1,0,img);
    % subplot(122), imagesc(img);

    img = imread('shapes_noise.tif');
    img = dualThresh(img,100,255);
    [width,height] = size(img);
    scale = 0.3;
    img = imresize(img,scale,'cubic');
    figure; imagesc(img);
    uiwait(msgbox('Click on starting seed point'));
    [xc,yc] = ginput(1);
    close;
    xc = round(xc); yc = round(yc);
    %[xc,yc] = ind2sub(size(img), find(img,1,'first'));
    call = 0;
    img = floodfill_It(xc,yc,2,1,img,8);
    img = imresize(img,[width height],'cubic');
    figure; imshow(img,[]); colorbar;
    title(sprintf('Flood fill. old label = %d, new label = %d',1,2));
    clear img; 
    disp('---------------------------------');
end
    
%% Connected component analysis
if conn_comp == 1,
    disp('Connected component analysis');

    I = imread('turkeys.tif');
    if size(I,3) > 1,
        I = rgb2gray(I);
    end
    minm = 0; maxm = 50;
    I = dualThresh(I,minm,maxm);
    [width,height] = size(I);
    img = zeros(size(I));
    [img,N] = ConnectedComponent(I,2,8);
    imagesc(img); title(sprintf('%d Connected components.  Threshold: [%d-%d]',N,minm,maxm));
    disp(sprintf('%d connected components found.\n',N));
    
    clear I; clear img; clear N; clear L;
end

%% Topological denoising
if top_denoise == 1,
    disp('Topological denoising'); 
    
    I = imread('denoise_1.png');
    if size(I,3) > 1,
        I = rgb2gray(I);
    end

    I = double(1-dualThresh(I,0,100));
    [img,N,L] = ConnectedComponent(I,2);
    disp(sprintf('%d connected components found\n',N));
    figure; subplot(121); imagesc(img); title('Original image');
    thresh = 150;
    for i=1:N
        if L(i) < thresh,
            ind = img == i;
            img(ind) = 0;
        end
    end
    subplot(122); imagesc(img); title('Denoised image');
    disp('---------------------------------');
end

%% Motion detection
if motion_detection == 1,
    
    I1 = imread('houndog1.tif');
    I1 = I1(:,:,1:3);
    if size(I1,3) > 1,
        I1 = rgb2gray(I1);
    end
    I2 = imread('houndog2.tif');
    I2 = I2(:,:,1:3);
    if size(I2,3) > 1,
        I2 = rgb2gray(I2);
    end
    J = abs(I2 - I1);
    J = im2bw(J,graythresh(J));
    img = zeros(size(J));
    [img,N,L] = ConnectedComponent(J,2,8);
    
    thresh = 150; % Set manually
    for i=1:N
        if L(i) < thresh,
            ind = img == i;
            img(ind) = 0;
            L(i) = -1;
        end
    end
    
    ind = L == -1;
    L(ind) = [];
    N = N - nnz(ind);
    disp(sprintf('%d connected components retained\n',N));
    figure; imagesc(img); title('Missing object');
end