function [ nmi ] = normalizedMutualInformation( X, Y, nbins )
    
    Pxy = jointProbability(X,Y,nbins);
    
    Px = sum(Pxy, 1);
    Py = sum(Pxy, 2);
    
    PxPy = repmat(Px,length(Py),1) .* repmat(Py,1,length(Px));
    
    nmi = sum(sum(Pxy(Pxy>0) .* log2(Pxy(Pxy>0) ./ PxPy(Pxy>0))));
    
    Hx = -sum(Px(Px>0) .* log2(Px(Px>0)));
    Hy = -sum(Py(Py>0) .* log2(Py(Py>0)));
    
    nmi = 2*nmi / (Hx + Hy);
end

