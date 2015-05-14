function [ SegmentationEstimation ] = majorityVoting( Segmentations )
%% computes per voxel majority voting
% each segmentation has the same influence -> no weighting
%
% Inputs:
%  Segmentations, struct-array with size 1xN
%   Segmentations(i).Volume, matrix: the segmentations estimation (label image)
%
% Outputs:
%  SegmentationEstimation, matrix: the resulting label image
%
%
% Author: Matthias Dorfer @ CIR Lab (Medical University of Vienna)
% email:  matthias.dorfer@meduniwien.ac.at
%

    % number of segmentations to be fused
    nSegmentations = length(Segmentations);

    % image or volume that count how often a voxel was suggested as
    % foreground
    MajorityCounter = zeros(size(Segmentations(1).Volume));

    % iterate all segmentations
    for iSeg = 1 : length ( Segmentations )
    
        Segmentation    = Segmentations(iSeg).Volume;
        MajorityCounter = MajorityCounter + ( Segmentation > 0 );
    end
    
    % estimate segmentation based on majority voting
    SegmentationEstimation = MajorityCounter >= ceil(nSegmentations / 2);
end
