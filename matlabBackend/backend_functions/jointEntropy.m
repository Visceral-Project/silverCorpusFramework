function [ H ] = jointEntropy(X, Y, nbins)

    if ( nargin > 2 )
        P = jointProbability(X, Y, nbins);
    else
        P = jointProbability(X, Y);
    end
    
    H = -sum(sum(P(P>0) .* log2(P(P>0))));
end