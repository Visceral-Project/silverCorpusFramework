function [ P ] = jointProbability(X, Y, nbins)

    % force X and Y to column vectors
    X = X(:);
    Y = Y(:);
    
    % calculate joint histogram
    M = [X,Y];
    if ( nargin > 2 )
        H = hist3(M, [nbins nbins]);
    else
        H = hist3(M);
    end
    
    % normalize joint histogram
    P = H / sum(H(:));
end
