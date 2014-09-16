%
% Creates a 2d Butterworth filter with the origin at the center
% 
% inputs:  
% -------
% size - an array with rows and columns for the filter
% D0 - the frequency cutoff distance, scaled to be between 0 and 1
% n - the order of the filter
%
% outputs:  
% --------
% H - the Butterworth filter
%
function H = create_butterworth(size, D0, n)

    % Allocate space for the filter
    H = zeros(size);

    % The number of steps in the u and v dimension
    steps_u = 1/(size(1)-1);
    steps_v = 1/(size(2)-1);
      
    % These are the array indices
    i=1;
    j=1;
    
    % Loop from -.5 to .5
    for u=-0.5:steps_u:0.5
        
        % Loop from -.5 to .5
        for v=-0.5:steps_v:0.5
       
            % Compute the Butterworth at this location
            H(i,j) = 1/((1+(sqrt(u*u+v*v))/D0)^(2*n));
            % Increment the j index
            j=j+1;
            
        end
        
        % Reset the j index
        j=1;
        % Increment the i index
        i=i+1;
        
    end

end