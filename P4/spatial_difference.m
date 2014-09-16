%
% Calculates average spatial difference
% 
% inputs:  
% -------
% im1 - an image
% im2 - an image
%
% outputs:  
% --------
% value - the average spatial difference
%
function value = spatial_difference(im1, im2)

    % Covert the images to double
    im1 = double(im1);
    im2 = double(im2);

    % Get the sizes of the images
    [rows1 cols1] = size(im1);
    [rows2 cols2] = size(im2);

    % If the images are not the same size there is a problem
    if ((rows1 ~= rows2) || (cols1 ~= cols2))
        error('Images must be the same size');
    end
        
    % Take the difference of the images
    diff = abs(im1 - im2);
    % Compute the average of the sum of the differences
    value = sum(sum(diff)) / (rows1*cols1);
    
end