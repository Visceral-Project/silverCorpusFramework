function [ CurrentSegmentations, SelectedSegmentations ] = simpleSegmentation( Segmentations, alpha, x, initialWeights )
%% computes SIMPLE segmentation estimation based on global weighted voting
% see paper
% "Label fusion in atlas-based segmentation using a selective and
% iterative method for performance level estimation (SIMPLE)."
% Lagerak et. al. (2010)
%
% Inputs:
%  Segmentations, struct-array with size 1xN
%   Segmentations(i).Volume, matrix: the segmentation estimation (label image)
%
% Outputs:
%  CurrentSegmentations, struct array: selected subset of input argument Segmentations
%  SelectedSegmentations
%
%  SelectedSegmentations, struct:
%   .SelectedSegmentations, vector: indices of selected segmentations taken
%   into account for label fusion
%   .performances, vector: performances (0..1) of selected segmentations
%   .allPerformances, vector: performances of all input segmentations (includes discarded ones)
%
%
% Author: Matthias Dorfer @ CIR Lab (Medical University of Vienna)
% email:  matthias.dorfer@meduniwien.ac.at
%

    % threshold parameter for simple segmentation
    % see the paper for this value
    if (nargin < 2); alpha = 1; end;

    % number of reconsideration iterations
    if (nargin < 3); x = 1; end;
    
    % iteration counter
    k = 1;

    % struct for selected segmentations in each iteration
    SelectedSegmentations                          = struct;
    idxSelected                                    = 1 : length(Segmentations);
    SelectedSegmentations(k).SelectedSegmentations = idxSelected;
    
    % propagate labels to subject (initial ground truth estimation)
    CurrentSegmentations = Segmentations;
    
    if nargin < 4
        GroundTruthEstimate  = majorityVoting(CurrentSegmentations);
    else
        GroundTruthEstimate = globalWeightedVoting(CurrentSegmentations, initialWeights);       
    end
    
    boolNoConsensusFound=0;
    
    
    %% iterate until the number of selected segmentations converges
    boolSelectionChanged = 1;
    
    while ( boolSelectionChanged )
        
        
        %% (1) estimate performance of each segmentation
        performances = NaN(length(CurrentSegmentations),1);
        for iSegmentation = 1 : length(CurrentSegmentations)
            performances(iSegmentation) = segmentationDice(GroundTruthEstimate, CurrentSegmentations(iSegmentation).Volume);
        end
        
        SelectedSegmentations(k).performances = performances;
        
        %% (2) keep only well performing segmentations
        
        % compute threshold
        theta = nanmean(performances) - alpha * nanstd(performances);
    
        % select well performing segmentations
        idxSelected = SelectedSegmentations(k).SelectedSegmentations(performances > theta);
        
        if ~isempty(idxSelected)
            % increase iteration count
            k = k + 1;
            
            
            %% (3) compute weighted majority voting for ground truth update
            GroundTruthEstimate = globalWeightedVotingOfBinary(Segmentations(idxSelected), performances(performances > theta));
            
            
            %% re-consider early discarded segmentations in the first x iterations
            if ( x > 0 )
                
                x = x - 1;
                
                CurrentSegmentations = Segmentations;
                idxSelected          = 1 : length(Segmentations);
                SelectedSegmentations(k).SelectedSegmentations = idxSelected;
                
                % compute convergence criterion
                boolSelectionChanged = 1;
            else
                
                SelectedSegmentations(k).SelectedSegmentations = idxSelected;
                CurrentSegmentations                           = Segmentations(idxSelected);
                
                % compute convergence criterion
                boolSelectionChanged = ( numel(SelectedSegmentations(k-1).SelectedSegmentations) ~= numel(SelectedSegmentations(k).SelectedSegmentations) );
            end
        else
            boolSelectionChanged=0;
            boolNoConsensusFound = 1;
        end
    end
    
    if boolNoConsensusFound
        SelectedSegmentations = [];
        
    else
        SelectedSegmentations = SelectedSegmentations(1:end-1);
    end
end