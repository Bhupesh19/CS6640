function [ outputMatrixList] = getTransformMatrixList( pointsMatrix, logicMatrix)

sizeM = size(pointsMatrix);

for i = 1:sizeM(1)
    for j = 1:sizeM(2)
        if i == j,
            continue;
        end
        
        if logicMatrix(i,j) == 0,
            continue;
        end
          
        dim = pointsMatrix{i,j}.dim;
        currentPoint = pointsMatrix{i,j}.pointList;
        remPoints = pointsMatrix{j,i}.pointList; % 1*N, points in transfer matrix
        dM = zeros(2*dim(1),8); 
        res = zeros(2*dim(1),1);
        
        for k=1:dim(1)
            currentTemp = currentPoint{1,k};
            remTemp = remPoints{1,k};
            dM(k,:) = ...
                [-currentTemp(1), -currentTemp(2), -1, 0, 0, 0, ...
                 currentTemp(1)*remTemp(1), currentTemp(2)*remTemp(1)];
            res(k,1) = -remTemp(1);
        end
        
        for k  = (dim(1)+1) : (dim(1)*2)
            currentTemp = currentPoint{1,k-dim(1)};
            remTemp = currentPoint{1,k-dim(1)};
            dM(k,:) = ...
                [0, 0, 0, -currentTemp(1), -currentTemp(2), -1, ...
                 currentTemp(1)*remTemp(2), currentTemp(2)*remTemp(2)];
            res(k,1) = -remTemp(2);
        end
        
        [U S V] = svd(dM);
        nonDiagS = S == 0;
        diagS = S ~= 0;
        tempS = S;
        tempS(nonDiagS) = 1;
        diagS = (diagS./tempS)';
        pointMatrix = [V*diagS*U'*res; 1];
        pointMatrix = (reshape(pointMatrix,3,3))';
        outputMatrixList{i,j} = pointMatrix;
    end
end
end