function [ minx, miny, maxx, maxy ] = computeBounds( dimM, refIndex, ...
                                       transformMatrixList, imageList)
% COMPUTEBOUNDS : computes the corner points of the resulting canvas
% Input : dimension of images, reference index, list of transformation
% matrices, list of images.
% 
% Output : <minx, miny, maxx, maxy> , corners of canvas
minx = 0; miny = 0;
[maxy,maxx,junk] = size(imageList{refIndex});

for i=1:dimM(1)
    if i == refIndex,
        continue;
    end
    s = size(imageList{i});
    transformMatrix = transformMatrixList{i, refIndex};
    bounds = ...
    [  0  s(2)   0    s(2);
       0    0    s(1) s(1);
       1    1      1      1
    ];

    for k=1:4
        txmBounds = transformMatrix * bounds(:,k);
        txmBounds = txmBounds ./ txmBounds(3);
        
%         txmBounds
        if txmBounds(1) < minx,
            minx = txmBounds(1);
        end
        if txmBounds(2) < miny,
            miny = txmBounds(2);
        end
        if txmBounds(1) > maxx,
            maxx = txmBounds(1);
        end
        if txmBounds(2) > maxy,
            maxy = txmBounds(2);
        end
    end
end
end