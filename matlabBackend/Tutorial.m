%
% This script provides a tutorial to generate silver corpus segmentations
% of a target structure by fusing segmentation estimates from
%
%  1.) by image registration methods propagated expert annotations 
%  2.) in a benchmark participating algorithms computed segmentations
%
% The framework stores all relevant information in a MySQL database. The
% tutorial shows how to acces and query tables in the DB.
%
% The tutorial is seperated in the following parts:
% 1.) Define a target volume and a target structure (to generate the SC
%     segmentation
% 2.) Get all annotated volumes of the same modality and perform 
%     pre-registration atlas selection (based on NMI)
% 3.) Get all participant segmentations available for the target structure
%     in the volume
% 4.) Perform label fusion (Majority Vote, Global Level Weighted Voting and
%     SIMPLE segmentation), store results on the disk and in the DB
%
% Author:  Markus Krenn @ CIR Lab 
% contact: markus.krenn@meduniwien.ac.at
%


% initialize framework
[VisceralPaths, logFile] = initializeFramework();

%% get a structure for which a silver corpus annotation should be generated
structureID = 1302; % right lung
DBTargetStructure = dbGetStructures( structureID, [], logFile);

%% get a volume for which a silver corpus annotation should be generated
isGoldCorpus = 0;
isSilverCorpus = 1;
SCVolumes =  dbGetVolumes( [], [], 'CTce', [], isGoldCorpus,isSilverCorpus, logFile);
DBTargetVolume = SCVolumes(1);

%% get all atlas candidates, i.e. volumes of the (annotated) gold corpus having the same modality and bodyregion
isGoldCorpus = 1;
isSilverCorpus = 0;
GCVolumes =  dbGetVolumes( [], [], DBTargetVolume.modality, DBTargetVolume.bodyRegion, isGoldCorpus,isSilverCorpus, logFile);

AtlasCandidates = cell(0);
aCounter = 0;
for iGC = 1 : numel(GCVolumes)

    % check if annotation is available
    [ GCAnnotation, status ] = dbGetExpertAnnotation( GCVolumes(iGC).patientID, GCVolumes(iGC).volumeID, DBTargetStructure.structureID,  logFile);

    if ~isempty(GCAnnotation)
        aCounter= aCounter+1;
        AtlasCandidates{aCounter} = GCVolumes(iGC);
    else
       % skip that atlas since the target structure is not annotated
       continue; 
    end
end

%% perform pre-registration atlas selection based on Normalized Mutual Information (NMI)
preRegAtlasSelection = 1;

if preRegAtlasSelection
    
    % define maximum number of atlases
    nMaxAtlases = 3;
    
    % load target image
    targetNii = load_untouch_nii_gzip([VisceralPaths.volumePath DBTargetVolume.filename]);
    nmiVector = [];
    for iAC = 1 : numel(AtlasCandidates)
        disp(num2str(iAC))
        currentAC = AtlasCandidates{iAC};
        
        % load atlas candidate volume
        acNii = load_untouch_nii_gzip([VisceralPaths.volumePath currentAC.filename]);
        
        % calculate NMI
        acTemp = imresize3D(single(acNii.img),size(targetNii.img));
        [ nmi ] = normalizedMutualInformation(single(targetNii.img), single(acTemp), 32);
        nmiVector = [nmiVector nmi]; %#ok<*AGROW>
    end
    
    [sortedNMI, sortIdx] = sort(nmiVector,'descend');
    sortedAtlases = AtlasCandidates(sortIdx);

    selectedAtlases = sortedAtlases(1:min(numel(sortedAtlases),nMaxAtlases));

else
    selectedAtlases = AtlasCandidates; %#ok<*UNRCH>
end

%% register selected atlases to target image and propagate annotations
nAtlases = numel(selectedAtlases);
propagatedAtlasSegmentations = struct([]);
atlasPerformanceWeights = [];

for iA= 1 : numel(selectedAtlases)
    currentAtlas = selectedAtlases{iA};

    % compute non-rigid registration and save in DB
    RegistrationResults = getRegistrationTransforms( currentAtlas, DBTargetVolume, 0, VisceralPaths, logFile );

    % load atlas annotation
    DBAtlasAnnotation = dbGetExpertAnnotation(currentAtlas.patientID,currentAtlas.volumeID,DBTargetStructure.structureID,logFile);
    AnnotationNii = load_untouch_nii_gzip([VisceralPaths.expertAnnotationPath DBAtlasAnnotation.filename]);
    
    % propagate the segmentation volume to the target volume
    [ propagatedAnnotationNii ] =  propagateVolumeToTarget( RegistrationResults,AnnotationNii.img);
    propagatedAtlasSegmentations(end+1).Volume = single(propagatedAnnotationNii.img);

    % get average segmentation performance of atlas on the target structure
    atlasSegmentations = dbGetAtlasSegmentations( currentAtlas.patientID,currentAtlas.volumeID,DBTargetStructure.structureID, [0 1], logFile);
    for i = 1 : numel(atlasSegmentations)
        performances(i) = atlasSegmentations(i).performance;
    end
    atlasPerformanceWeights = [atlasPerformanceWeights mean(performances)];
end

%% get participant segmentations available of target structure in the volume 
[ DBAvailableParticipantSegmentations, status ] = dbGetParticipantSegmentation( DBTargetVolume.patientID, DBTargetVolume.volumeID,[], [], DBTargetStructure.structureID, ...
    [],  [],logFile );

participantSegmentations = struct([]);
participantPerformanceWeights = [];

for i = 1 : numel(DBAvailableParticipantSegmentations)
    currPartSeg = DBAvailableParticipantSegmentations(i);
    
    % load segmentation
    partSegNii = load_untouch_nii_gzip([VisceralPaths.participantSeg currPartSeg.filename]);
    participantSegmentations(end+1).Volume=partSegNii.img;
    
    % get average performance of current participant on target structure in
    % the target modality
    [ performances, status ] = dbGetParticipantSegmentationPerformances( [], [],DBTargetVolume.modality, DBTargetVolume.bodyRegion, DBTargetStructure.structureID, ...
        currPartSeg.participantID,  [0 1], logFile );
    participantPerformanceWeights = [participantPerformanceWeights mean(performances)];
end

%% perform label fusion
% prepare data
Segmentations = [propagatedAtlasSegmentations participantSegmentations];
weights = [atlasPerformanceWeights participantPerformanceWeights];

%% Majority Voting
[ SegmentationEstimation ] = majorityVoting( Segmentations );

% save to disk
SegmentationNii = targetNii;
SegmentationNii.img = SegmentationEstimation;
filename = [DBTargetVolume.patientID '_' num2str(DBTargetVolume.volumeID) '_' num2str(DBTargetStructure.structureID) '_MV.nii.gz'];
save_untouch_nii_gzip( SegmentationNii, [VisceralPaths.scSegmentations filename] );

% add to database
dbAddSilverCorpusSegmentation( DBTargetVolume.patientID, DBTargetVolume.volumeID, DBTargetStructure.structureID, 1, filename,[],logFile );

%% Global Weighted Voting
[ SegmentationEstimation ] = globalWeightedVoting(Segmentations, weights);

% save to disk
SegmentationNii = targetNii;
SegmentationNii.img = SegmentationEstimation;
filename = [DBTargetVolume.patientID '_' num2str(DBTargetVolume.volumeID) '_' num2str(DBTargetStructure.structureID) '_GWV.nii.gz'];
save_untouch_nii_gzip( SegmentationNii, [VisceralPaths.scSegmentations filename] )

% add to database
dbAddSilverCorpusSegmentation( DBTargetVolume.patientID, DBTargetVolume.volumeID, DBTargetStructure.structureID, 2, filename,[],logFile )

%% SIMPLE segmentation

% set parameters
alpha = 1.5;
x=3;
% SIMPLE algorithm
[ CurrentSegmentations, SelectedSegmentations ] = simpleSegmentation( Segmentations, alpha, x, weights );

% compute weighted label fusion based on simple output
selectedIdx             = SelectedSegmentations(end).SelectedSegmentations;
performances            = SelectedSegmentations(end).performances;
SegmentationEstimation  = globalWeightedVoting(Segmentations(selectedIdx), performances);

% save to disk
SegmentationNii = targetNii;
SegmentationNii.img = SegmentationEstimation;
filename = [DBTargetVolume.patientID '_' num2str(DBTargetVolume.volumeID) '_' num2str(DBTargetStructure.structureID) '_SIMPLE.nii.gz'];

% add to database
dbAddSilverCorpusSegmentation( DBTargetVolume.patientID, DBTargetVolume.volumeID, DBTargetStructure.structureID, 3, filename,[],logFile )

