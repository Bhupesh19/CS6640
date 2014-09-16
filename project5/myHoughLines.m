function [ H, varargout ] = myHoughLines( Bw, rhoRes, theta, thresh, numPeaks )
% MYHOUGH
% The Hough transform algorithm to compute the lines in binary image Bw

% Make sure Bw is binary
if ~isequal(unique(Bw),[0 1]'),
    error('Image should be binary. Returning original image');
end

if ~exist('rhoRes','var'),
    rhoRes = 1;
end

[width,height] = size(Bw);
maxR = round(sqrt(width^2 + height^2));
gapSize = 5;
rho = -maxR:rhoRes:maxR;

% Accumulator
H = zeros(length(rho), length(theta));

tic;
for r=1:width
    for c=1:height
        % Fill in accumulator
    
        for k = 1:length(theta)
            ang = theta(k)*pi/180;
            p = (r-1)*cos(ang) + (c-1)*sin(ang);
            [d,ind] = min(abs(rho-p));
            if d <= 1,
                H(ind,k) = H(ind,k) + 1;
            end
        end
    end
end
toc;

if ~exist('thresh','var') || isempty(thresh),
    thresh = 0.3 *max(H(:));
end

if ~exist('numPeaks','var') || isempty(numPeaks),
    numPeaks = length(H);
end

done = 0;
p = [];
HH = bilfilt2(H,3,3,1);

[~,K] = sort(HH(:),'descend');
[rp,tp] = ind2sub(size(HH), K);
% while ~done,
%     [~,ind] = max(HH(:));
%     [r,t] = ind2sub(size(HH),ind);
%     r = r(1); t = t(1);
%     
%     if HH(r,t) >= thresh,
%         p = [p; [r t]];
%         HH(r,t) = 0;
%         done = size(p,1) == numPeaks;
%     end
% end

%clear K; clear HH;
% rp = p(:,1);
% tp = p(:,2);
numPeaks = min(numPeaks, length(rp));
rp = rp(1:numPeaks);
tp = tp(1:numPeaks);

figure,imagesc(H); colormap gray; hold on;
xlabel('\theta'); ylabel('\rho');
axis on, axis normal, hold on;
plot(tp,rp,'s','color','white');

%% 
[y,x] = find(Bw);
pix = [x y] - 1;
c = pix(:,2);
r = pix(:,1);
len = length(rho);
m = (len - 1) / (rho(end) - rho(1));
X = []; Y = [];
% idea from houghlines.m
for i=1:length(rp)
    ang = theta(tp(i)) * pi / 180;
    p = r*cos(ang) + c*sin(ang);
    bins = round(m*(p - rho(1)) + 1);
    idx = find(bins == rp(i));
    x = c(idx)+1;
    y = r(idx)+1;
    
    X = [X; x];
    Y = [Y; y];
end

% Get direction of lines( vertical / horizontal )
lenx = max(X) - min(X);
leny = max(Y) - min(Y);
if lenx > leny,
    order = [1 2];
else 
    order = [2 1];
end

xynew = sortrows([X Y], order);
X = xynew(:,1);
Y = xynew(:,2);

%% Get line segments

xynew = [ Y X ];
sumdiff = sum(((xynew(1:end-1,:) - xynew(2:end,:)).^2),2);
point1 = []; point2 = [];
gap_idx = find(sumdiff > gapSize*gapSize);
idx = [0  ; gap_idx ; size(xynew,1)];
for i=1:length(idx)-1
    p1 = xynew(idx(i) + 1, :);
    p2 = xynew(idx(i+1), :);
    point1 = [point1; p1];
    point2 = [point2; p2];
end

if nargout > 1,
    varargout{1} = [point1 point2];
end

 %% Display
 figure, imagesc(Bw); colormap gray; hold on; axis off;
 for i = 1: length(point1)
     xy = [point1(i,:); point2(i,:)];
     plot(xy(:,1), xy(:,2), 'Color','r');
     
%      plot(xy(1,1), xy(1,2), 'x', 'Linewidth',2,'Color','b');
%      plot(xy(2,1), xy(2,2), 'x', 'Linewidth',2,'Color','g');
 end
end