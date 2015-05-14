function [ dice ] = segmentationDice(SegmentationI, SegmentationJ)
%% compute dice coefficient between two segmentations
%
%   AUTHOR: Matthias Dorfer @ CIR / meduniwien
%           e-mail: matthias.dorfer@gmx.at
%
    
    % voxels in the individual images
    nVoxelI = ( SegmentationI ~= 0 );
    nVoxelI = sum(nVoxelI(:));
    nVoxelJ = ( SegmentationJ ~= 0 );
    nVoxelJ = sum(nVoxelJ(:));
    
    % number of mathing voxel
    nIntersection = (SegmentationI ~= 0) & (SegmentationJ ~= 0);
    nIntersection = sum(nIntersection(:));
    
    % compute dice
    dice = 2*nIntersection / ( nVoxelI + nVoxelJ );
end