%
% Performs phase correlation
% 
% inputs:  
% -------
% f - image f which is the moving image
% g - image g which is stationary
% threshold - only accept peaks above this
%
% outputs:  
% --------
% overlap - a boolean which denotes overlap
% x - the row offset of the upper left corner of f into g
% y - the column offset of the upper left corner of f into g
%
function [overlap x y] = phase_correlation(f, g, threshold)

    % Get the size of the images
    [rows_f cols_f] = size(f);
    [rows_g cols_g] = size(g);
    
    %---------------------------------------------------------
    % MAKE SURE THE IMAGES ARE THE SAME SIZE
    %---------------------------------------------------------
        
    % If g has more rows than f
    if (rows_f < rows_g)
        
        % We need to offset f a bit
        offset_fx = rows_g - rows_f;
        % We don't offset g
        offset_gx = 0;
    else
        
        % We don't offset f
        offset_fx = 0;
        % We need to offset g a bit
        offset_gx = rows_f - rows_g;
        
    end
    
    % If g has more columns than f
    if (cols_f < cols_g)
        
        % We need to offset f a bit
        offset_fy = cols_g - cols_f;
        % We don't offset g
        offset_gy = 0;
        
    else
        
        % We don't offset f
        offset_fy = 0;
        % We need to offset g a bit
        offset_gy = cols_f - cols_g;
    end
    
    % Create two images that are the desired size for f and g and fill
    % them with the mean value of the respected image.
    wf = mean(mean(f)).*ones(rows_f + offset_fx, cols_f + offset_fy);
    wg = mean(mean(g)).*ones(rows_g + offset_gx, cols_g + offset_gy);
    
    % Place f and g in the upper left corner of the bigger images
    wf(1:rows_f, 1:cols_f) = double(f);
    wg(1:rows_g, 1:cols_g) = double(g);
    
    %---------------------------------------------------------
    % DO PHASE CORRELATION
    %---------------------------------------------------------

    % Create a low pass filter
    H = create_butterworth(size(wf), 0.15, 1);

    % Compute the fft of image f and shift
    F = fftshift(fft2(wf));
    % Compute the fft of image g and shift
    G = fftshift(fft2(wg));

    % Compute the conjugate of F
    Fstar = conj(F);

    % Perform phase correlation
    F_phase = H .* ((Fstar.*G) ./ (abs(Fstar).*abs(G)));

    % Get the phase image
    phase_im = ifft2(ifftshift(F_phase));

    % Find the peak
    [biggest index] = max(real(phase_im(:)));
    avg = mean(real(phase_im(:)));
    
    % Find the x and y offsets for the peak
    x = mod(index,size(phase_im,1));
    y = ceil(index/size(phase_im,1));
        
    % If the peak stands out
    if ((biggest-avg) < threshold)
    
        % The two images do not overlap
        overlap = false;
        return;
    
    end
    
    % Set the boolean flag to true -- the images overlap
    overlap = true;
      
    %---------------------------------------------------------
    % RESOLVE AMBIGUITY
    %---------------------------------------------------------
    
    % x and y ranges for f
    xf = [1 rows_f-x+1; 1 (rows_f-x+1); (rows_f-x+1) rows_f; (rows_f-x+1) rows_f];
    yf = [1 (cols_f-y+1); (cols_f-y+1) cols_f; 1 (cols_f-y+1); (cols_f-y+1) cols_f]; 
    
    % x and y ranges for g
    xg = [x rows_g; x rows_g; 1 x; 1 x];
    yg = [y cols_g; 1 y; y cols_g; 1 y];
    
    % Set the minimum spatial difference to be false
    min_diff = inf;
    % Set a default best index
    best_index = -1;
    
    % Loop over the four ambiguious cases
    for i=1:4
       
        % Create the regions of overlap
        im_subf = wf(xf(i,1):xf(i,2), yf(i,1):yf(i,2));
        im_subg = wg(xg(i,1):xg(i,2), yg(i,1):yg(i,2));

        % Compute the spatial difference
        diff = spatial_difference(im_subf, im_subg);
        
        % Update the best difference and index
        if (diff < min_diff)
            
            min_diff = diff;
            best_index = i;
            
        end

    end
        
    % The top right corner of f goes on pixel x y in g
    if (best_index == 2)
        
        % The y is translated
        y = y - cols_f;
        
    % The bottom left corner of f goes on pixel x y in g
    elseif (best_index == 3)
        
        % The x is translated
        x = x - rows_f;
        
    % The bottom right corner of f goes on pixel x y in g
    elseif (best_index == 4)
        
        % The x is translated
        x = x - rows_f;
        % The y is translated
        y = y - cols_f;
        
    end
     
end