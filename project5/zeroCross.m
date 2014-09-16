function [ e ] = zeroCross( B, thresh )
% zeroCross
% Algorithm to determine zero-crossing of the image

[m,n] = size(B);
rr = 2:m-1;
cc = 2:n-1;
e = zeros(m,n);
if ~exist('thresh','var') || isempty(thresh),
    thresh = 0.75 * mean2(abs(B));
end

%[r,c] = find( B(rr,cc) < B(rr,cc+1) );
[r,c] = find( B(rr,cc) < 0 & B(rr,cc+1) > 0 & ...
                abs(B(rr,cc) - B(rr,cc+1)) > thresh); % [- +] 
e((r+1) + c*m) = 1;

% [r,c] = find( B(rr,cc) < B(rr,cc-1) );
[r,c] = find( B(rr,cc) < 0 & B(rr,cc-1) > 0 & ...
                abs(B(rr,cc-1) - B(rr,cc)) > thresh); % [+ -]
e((r+1) + c*m) = 1;
% [r,c] = find( B(rr,cc) < B(rr+1,cc) );
[r,c] = find( B(rr,cc) < 0 & B(rr+1,cc) > 0 & ...
                abs(B(rr,cc) - B(rr+1,cc)) > thresh); % [ - ]
e((r+1) + c*m) = 1;                                   % [ + ]

% [r,c] = find( B(rr,cc) < B(rr-1,cc) );
[r,c] = find( B(rr,cc) < 0 & B(rr-1,cc) > 0 & ...     % [ + ]
                abs(B(rr,cc) - B(rr-1,cc)) > thresh); % [ - ]
e((r+1) + c*m) = 1;

end