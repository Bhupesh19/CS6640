%
% Automatically mosaics the given files using phase correlation
% for image registration.
% 
% inputs:  
% -------
% filenames - a cell array of image filenames
% threshold - the threshold for phase correlation peaks
%
% outputs:  
% --------
% mosaic - the final mosaic image
%
function mosaic = auto_mosaic(filenames, threshold)

    % Get the number of files        
    num_files = length(filenames);
    % Create a cell array to hold the images
    images = cell(1,num_files);

    % Read in all the input files
    for i=1:num_files

        % Read in the images as gray scale images
        images{i} = read_image(filenames{i},0);

    end

    % An upper triangular matrix of boolean values which denotes
    % if two images overlap
    do_overlap = zeros(num_files, num_files);
    % An upper triangular matrix of local offsets between images
    offsets = cell(num_files, num_files);

    %---------------------------------------------
    % CALCULATE OVERLAP AND OFFSETS
    %---------------------------------------------

    % Loop over all images
    for i=1:num_files

        % Loop over the remaining images
        for j=i+1:num_files

            % Get image f
            f = images{j};
            % Get image g
            g = images{i};

            % Do phase correlation
            [do_overlap(i,j) x y] = phase_correlation(f, g, threshold);

            % If they overlap
            if (do_overlap(i,j))

                % Store the local offsets between the images
                cur_offsets = [x y];
                offsets{i,j} = cur_offsets;

            end

        end

    end

    %---------------------------------------------
    % BUILD THE CANVAS
    %---------------------------------------------

    % The pixel location of the upper left hand corner on the canvas
    canvas_location = cell(1,num_files);
    % A boolean value which denotes if an image has been placed on the canvas
    on_canvas = zeros(1,num_files);

    % Put the first image on the canvas
    mosaic = images{1};

    % The first image is at location (1,1) on the canvas
    canvas_location{1} = [1 1];
    % The first image is on the canvas, so we update our boolean array
    on_canvas(1) = true;
    % The current image is now the second one
    cur_image = 2;

    % Keep going until all images are on the canvas
    while (length(unique(on_canvas))>1) 

        % If the current image is not on the canvas we need to put it on
        if (~on_canvas(cur_image))

            canvas_image = -1;

            % Find an image already on the canvas it aligns with
            for i=1:num_files

                % If the two images overlap and image i is on the canvas
                if (do_overlap(i, cur_image)) && (on_canvas(i))

                    % Make image i the canvas image
                    canvas_image = i;
                    break;

                end

            end

            % If we didn't find a match we need to try another image
            if (canvas_image == -1)

                % Increment the current image and mod to wrap around
                cur_image = mod(cur_image, num_files)+1;
                continue;

            end

            % Now we know that cur_image needs to move onto canvas_image

            % Get the images
            g = mosaic;
            f = images{cur_image};

            % How much locally the cur_image image needs to move to be on canvas_image
            cur_offsets = offsets{canvas_image, cur_image};

            % The location of the canvas image on the canvas
            can_x = canvas_location{canvas_image}(1) - 1;
            can_y = canvas_location{canvas_image}(2) - 1;

            % The total amount of movement needed to move the current image to the canvas image
            x = cur_offsets(1) + can_x;
            y = cur_offsets(2) + can_y;

            % Get the sizes of the two images
            [rows_f cols_f] = size(f);
            [rows_g cols_g] = size(g);

            % Determine the canvas rows
            if (x <= 0)        
                canvas_rows = rows_g + abs(x);
            else
                canvas_rows = max(rows_g, rows_f+x);
            end

            % Determine the canvas columns
            if (y <= 0)                
                canvas_cols = abs(y) + cols_g;
            else
                canvas_cols = max(cols_g, cols_f+y);
            end

            % Create a blank canvas
            mosaic = uint8(zeros(canvas_rows, canvas_cols));

            % If they are both positive we can stick g at the origin
            if (x > 0) && (y > 0)

                % Place g at the origin
                mosaic(1:rows_g, 1:cols_g) = g;
                % Shift f the desired amount
                mosaic(x+1:rows_f+x, y+1:cols_f+y) = f;

                % Update the location of the canvas image
                canvas_location{cur_image} = [x+1 y+1];

                % This is how much the canvas has shifted
                can_off_x = 1;
                can_off_y = 1;

            % We need to shift g over to the right by abs(y) pixels
            % and place f along the vertical axis
            elseif (x > 0) && (y <= 0)

                % Shift g the desired amount
                mosaic(1:rows_g, abs(y-1):cols_g+abs(y-1)-1) = g;
                % Shift f the desired amount
                mosaic(x+1:rows_f+x, 1:cols_f) = f;

                % Update the location of the canvas image
                canvas_location{cur_image} = [x+1 1];

                % This is how much the canvas has shifted
                can_off_x = 1;
                can_off_y = abs(y-1);

            % We need to shift g down y abs(x+1) pixels
            % and place f along the horizontal axis
            elseif (x <= 0) && (y > 0)

                % Shift g the desired amount
                mosaic(abs(x-1):rows_g+abs(x-1)-1, 1:cols_g) = g;
                % Shift f the desired amount
                mosaic(1:rows_f, y+1:cols_f+y) = f;

                % Update the location of the canvas image
                canvas_location{cur_image} = [1 y+1];

                % This is how much the canvas has shifted
                can_off_x = abs(x-1);
                can_off_y = 1;

            % We need to shift g to the right and down and
            % place f at the origin
            else

                % Shift g the desired amount
                mosaic(abs(x-1):rows_g+abs(x-1)-1, abs(y-1):cols_g+abs(y-1)-1) = g;
                % Place f at the origin
                mosaic(1:rows_f, 1:cols_f) = f;

                % Update the location of the canvas image
                canvas_location{cur_image} = [1 1];

                % This is how much the canvas has shifted
                can_off_x = 1;
                can_off_y = abs(y-1);

            end

            %---------------------------------------------
            % UPDATE CANVAS LOCATIONS
            %---------------------------------------------

            % Loop over all the images
            for i=1:num_files

                % If the image is on the canvas we need to update its position
                if (on_canvas(i))

                    % Get the current location
                    cur_off_x = canvas_location{i}(1);
                    cur_off_y = canvas_location{i}(2);

                    % Modify the location and store it
                    canvas_location{i} = [can_off_x+cur_off_x-1 can_off_y+cur_off_y-1];

                end

            end

            % The current image is on the canvas, so we denote it as such
            on_canvas(cur_image) = true;
            % Move to the next image
            cur_image = mod(cur_image,6)+1;

        end

    end

end