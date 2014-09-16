% clear all;
close all;

paramFname = 'building.txt';

if ~isempty(paramFname),
    fp = fopen(paramFname,'r');
else
    return;
end

%% Read entire param file excluding comments
ind = 1;
while ~feof(fp),
    l = fgetl(fp);
    if size(l) == [0 0],
        disp(l);
        continue;
    end
    if l(1) ~= '/'
        file{ind} = l;
        ind = ind+1;
    end
end

fclose(fp);

%% Parse each section
lineNum = 1;
dimM = sscanf(file{lineNum}, '%d %d'); % read dimensions
adjM = zeros(dimM(1), dimM(2));
for i=1:dimM(1)
    adjM(i,:) = sscanf(file{lineNum+i},'%f'); % read relative matrix
end
lineNum = lineNum + dimM(1);

for i=1:dimM(1),
  fileList{i} = file{lineNum+i};  % read image list
end
lineNum = lineNum + dimM(1);

for k=1:2*(dimM(1)-1) % read correspondence points
    lineNum = lineNum + 1;
    pos = sscanf(file{lineNum},'%d');
    
    lineNum = lineNum + 1;
    d = sscanf(file{lineNum},'%d');
    
    for i=1:d(1)
        lineNum = lineNum + 1;
        points{i} = sscanf(file{lineNum},'%d');
%         points{i} = points{i}(end:-1:1);
%         points{i} = { points1(2), points1(1)};
    end
    
    corrPoint.dim = d;
%     corrPoint.pointList = points;
    corrPoint.points = points;
    pointsMatrix{pos(1)+1, pos(2)+1} = corrPoint;
    logicMatrix(pos(1)+1, pos(2)+1) = 1; % 
end

lineNum = lineNum + 1;
refIndex = sscanf(file{lineNum},'%d'); % name of reference image

lineNum = lineNum + 1;
opImage = file{lineNum}; % name of output image

% Load all the images
for i=1:dimM(1)
    imageList{i} = imread(fileList{i});
    imageList{i} = double(imageList{i});
end

% 
imageList = contrastAdjust(imageList, refIndex);

%% Mosaic

% Get list of transformation Matrices and fill the values
% transformMatrixList = getTransformMatrixList(pointsMatrix, logicMatrix);
transformMatrixList = getTransM(pointsMatrix, logicMatrix);
transformMatrixList = fillTransformMatrixList(transformMatrixList, logicMatrix);

% Build the canvas
[minx, miny, maxx, maxy] = computeBounds(dimM, refIndex, transformMatrixList, ...
                            imageList);
                        
%% Fill the canvas
lims = [floor(maxy-miny)+20, floor(maxx-minx)+20];
canvas = zeros(lims(1),lims(2),3);
minx = floor(minx); miny = floor(miny);

for j = 1:lims(1)
  for i = 1:lims(2)
      coord = [i+minx-10; j+miny-10; 1];
      pixValue = [0; 0; 0];
      dBound = 0;
      
    for k=1:dimM(1)
      curImage = imageList{k};
      curImageSize = size(curImage);

      if k == refIndex,
          imgCoord = floor(coord) + [1; 1; 0];
          if isValid(imgCoord(1),imgCoord(2),curImageSize(2),curImageSize(1)),
              val = curImage(imgCoord(2), imgCoord(1),:);
              d = [imgCoord(1) imgCoord(2) abs(curImageSize(2)-imgCoord(1)) abs(curImageSize(1)-imgCoord(2))];
              val = val*min(d);
              dBound = dBound + min(d);
              pixValue = pixValue + val(:);
          end
      else
          transformMatrix = transformMatrixList{refIndex, k};
          imgCoord = transformMatrix*coord;
          imgCoord = imgCoord ./ imgCoord(3)+[1; 1; 0];
          
%           if abs(imgCoord(1)) < 1,
%               disp(imgCoord(1));
%           end
         
          if isValid(imgCoord(1),imgCoord(2),curImageSize(2),curImageSize(1)),
              x0 = imgCoord(2); y0 = imgCoord(1);
              val = curImage(max(1,floor(x0)), max(1,floor(y0)),:);
              d = [x0 y0 abs(curImageSize(1)-x0) abs(curImageSize(2)-y0)];
              val = val*min(d);
              dBound = dBound + min(d);
              pixValue = pixValue + val(:);
          end
      end
    end
    
    if sum(pixValue(:)) == 0,
        continue;
    end
    
    if dBound ~= 0,
        pixValue = pixValue / dBound;
        canvas(j,i,:) = pixValue;
    end
  end
end

figure, imshow(uint8(canvas));
imwrite(uint8(canvas),opImage);