function [ SegmentationEstimation ] = globalWeightedVoting(Segmentations, weights)
%% computes per voxel global weighted majority voting (one weight for the entire image region)
%
% Inputs:
%  Segmentations, struct-array with size 1xN
%   Segmentations(i).Volume, matrix: the segmentations estimation (label image)
%  weights, 1xN double vector: the weiths for the corresponding
%  segmentations
%
% Outputs:
%  SegmentationEstimation, matrix: the resulting label image
%
%
% Author: Matthias Dorfer @ CIR Lab (Medical University of Vienna)
% email:  matthias.dorfer@meduniwien.ac.at
%

    % image or volume that counts how often a voxel was suggested as
    % foreground
    MajorityCounter = zeros(size(Segmentations(1).Volume));

    % normalize weiths to range [0 1]
    weights = weights / max(weights);
    
    % iterate all segmentations
    for iSeg = 1 : length ( Segmentations )
    
        WeightedSegmentation = (Segmentations(iSeg).Volume > 0) * weights(iSeg);
        MajorityCounter      = MajorityCounter + WeightedSegmentation;
    end
    
    % estimate segmentation based on majority voting
    SegmentationEstimation = MajorityCounter >= (sum(weights) / 2);
    SegmentationEstimation = double(SegmentationEstimation);
end
