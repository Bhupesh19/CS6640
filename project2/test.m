filename = 'lunch.jpg';
dot = find(filename == '.');
pref = filename(1:dot-1);
ext = filename(dot+1:end);

I = imread(filename);

if size(I,3) >= 3,
    I = rgb2gray(I(:,:,1:3));
end

%% Set parameter values
nbins = 256;
minm = double(min(I(:)));
maxm = double(max(I(:)));

%% HISTEQ(I,NBINS)
[~,Heq] = histogram_eq(I,nbins,minm,maxm);
close;

%% IDENTITY TRANSFORM
rng = size(Heq,2);
Hi = linspace(minm, maxm, rng) / (rng);

% blending param
alpha = 1.0; % optimal result = 0.25

% blended transform
Hf = alpha * Heq + (1-alpha) * Hi;

%% APPLY TRANSFORM
[row,col] = size(I);
res = uint8(zeros(row,col));

sc = uint8(length(Hf)/255);

for r = 1:row
    for c = 1:col
        ind = uint8(I(r,c)*sc + 0.5);
        res(r,c) = uint8( 255.0 * Hf(ind) + 0.5);
    end
end

%% DISPLAY RESULTS
filename = sprintf('%s_%.2f.%s',pref,alpha,ext);
imwrite(res,filename);
subplot(121); imshow(I,[]); title('Original Image');
subplot(122); imshow(res,[]); title('Transformed Image');