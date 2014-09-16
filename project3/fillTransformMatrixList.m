function [resList] = fillTransformMatrixList( transformMatrixList, logicMatrix)

  [m,n] = size(transformMatrixList);
  resList = transformMatrixList;
  tempL = logicMatrix;
  
  if m ~= n,
      return;
  end
  
  for r=1:m
    for c=1:r
          
     if r==c,
      continue;
     else
      if tempL(r,c) == 0,
         levels = 0;
         fillMatrix = getPath(r,c,transformMatrixList,logicMatrix,...
                    eye(3), levels);
         resList{r,c} = fillMatrix; 
         resList{c,r} = pinv(fillMatrix);
         tempL(r,c) = 1; tempL(c,r) = 1;
      end
     end
         
    end
  end
  
end

function [fillMatrix] = getPath(y,x,txmMatList, logicMatrix, idMatrix, level)

 [m,n] = size(logicMatrix);
 if m ~= n,
     fillMatrix = zeros(m,m);
     return;
 end
 
 level = level + 1;
 if level > m,
     fillMatrix = zeros(m,m);
     return;
 end
 
 % if value found
 if logicMatrix(y,x) == 1,
     fillMatrix = txmMatList{y,x}*idMatrix;
     return;
 end
 
 for k=1:m
     if logicMatrix(y,k) == 1,
         tempFillMatrix = txmMatList{y,k}*idMatrix;
         tempFillMatrix = getPath(k, x, txmMatList, logicMatrix, ...
             tempFillMatrix, level + 1);
         
         if sum(tempFillMatrix(:)) ~= 0,
             fillMatrix = tempFillMatrix;
             return;
         end
     end
 end
 
 fillMatrix = zeros(m,m);
 return;
end