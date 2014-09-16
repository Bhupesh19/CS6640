function [ resImageList ] = contrastAdjust( imageList, refIndex )

  [~,n] = size(imageList);
  refImage = imageList{refIndex};
  sizeRef = size(refImage);
  numPixels = prod(sizeRef(1:2));
  rChannel = refImage(:,:,1);
  gChannel = refImage(:,:,2);
  bChannel = refImage(:,:,3);
  
  avgR = sum(rChannel(:))/numPixels;
  avgG = sum(gChannel(:))/numPixels;
  avgB = sum(bChannel(:))/numPixels;
  
  resImageList = imageList;
  
  for i=1:n
      if i == refIndex,
          continue;
      end
      tempImage = imageList{i};
      d = size(tempImage);
      pix = prod(d(1:2));
      tempR = tempImage(:,:,1); tempAvgR = sum(tempR(:))/pix;
      tempG = tempImage(:,:,2); tempAvgG = sum(tempG(:))/pix;
      tempB = tempImage(:,:,3); tempAvgB = sum(tempB(:))/pix;
      
      tempImage(:,:,1) = tempImage(:,:,1) + (avgR - tempAvgR);
      tempImage(:,:,2) = tempImage(:,:,2) + (avgG - tempAvgG);
      tempImage(:,:,3) = tempImage(:,:,3) + (avgB - tempAvgB);
      
      resImageList{i} = tempImage;
  end
end