function [ RegistrationTransforms ] = getRegistrationTransforms( DBSourceVolume, DBTargetVolume, affineOnly, VisceralPaths, logFile )
%
% Author: Markus Krenn @ CIR Lab (Medical University of Vienna)
% email:  markus.krenn@meduniwien.ac.at
%
% Computes or loads (if already computed) affine and non-rigid registration
% transformations of two volumes from the same modality covering the same
% body region.
%
% This function uses the Nifty-Reg toolbox
% (http://cmictig.cs.ucl.ac.uk/wiki/index.php/NiftyReg) to compute affine
% and non-rigid image transformations.
%
%
% Returns a struct holding paths to
%   Source Volume
%   Target Volume
%   Affine transformation matrix
%   Non-rigid transformation field 
%
% The resulting struct can then be used to propagate label volumes from the
% source image to the target image (propagateVolumeToTarget).
%

functionName = 'getRegistrationTransforms';

% path for temporary nifty reg files
tempDir = './niftyRegTemp/';

useGPU = 0;

if ~exist(tempDir,'dir'); mkdir(tempDir); end;
%% set parameters of nifty reg toolbox - parameter settings are set for different modalities based on cross validation segmentation performance evaluation 

switch DBSourceVolume.modality
    case 'CT'
        AffineOptions.ln    = 5;
        AffineOptions.lp    = 2;
        
        NROptions.ln    = 4;
        NROptions.lp    = 3;
        NROptions.sx    = 9;
        NROptions.be    = 0.00008;
        NROptions.maxit = 3000;
        NROptions.gpu   = 1;
        
    case 'CTce'
        AffineOptions.ln    = 5;
        AffineOptions.lp    = 2;
        
        NROptions.ln    = 3;
        NROptions.lp    = 2;
        NROptions.sx    = 7;
        NROptions.be    = 0.00008;
        NROptions.maxit = 3000;
        NROptions.gpu   = 1;
        
    case 'MRT1'
        AffineOptions.ln    = 5;
        AffineOptions.lp    = 1;
        
        NROptions.ln    = 3;
        NROptions.lp    = 2;
        NROptions.sx    = 7;
        NROptions.sy    = -2;
        NROptions.sz    = 7;
        NROptions.be    = 0.00008;
        NROptions.maxit = 3000;
        NROptions.gpu   = 1;
        
    case 'MRT2'
        AffineOptions.ln    = 5;
        AffineOptions.lp    = 2;
        
        NROptions.ln    = 3;
        NROptions.lp    = 2;
        NROptions.sx    = 7;
        NROptions.sy    = -2;
        NROptions.sz    = 7;
        NROptions.be    = 0.00008;
        NROptions.maxit = 3000;
        NROptions.gpu   = 1;
        
        
    otherwise
        AffineOptions.ln    = 5;
        AffineOptions.lp    = 2;
        
        NROptions.ln    = 3;
        NROptions.lp    = 2;
        NROptions.sx    = 7;
        NROptions.be    = 0.00008;
        NROptions.maxit = 3000;
        NROptions.gpu   = 1;
end
%% get volume IDs from structs
sourcePatientID = DBSourceVolume.patientID;
sourceVolumeID  = DBSourceVolume.volumeID;
targetPatientID = DBTargetVolume.patientID;
targetVolumeID  = DBTargetVolume.volumeID;
                                    
affineFileName = [num2str(sourcePatientID) '_' num2str(sourceVolumeID) '_to_' num2str(targetPatientID) '_' num2str(targetVolumeID) '_affine.txt'];
cppFilename = [num2str(sourcePatientID) '_' num2str(sourceVolumeID) '_to_' num2str(targetPatientID) '_' num2str(targetVolumeID) '_cppNii.nii'];


%% path to source and target image niis
SourceVolumePath    = [ VisceralPaths.volumePath DBSourceVolume.filename];
TargetVolumePath    = [ VisceralPaths.volumePath DBTargetVolume.filename];

%% initialize result struct
RegistrationTransforms.affineFilePath       = [];
RegistrationTransforms.cppNiiFilePath       = [];
RegistrationTransforms.SourceVolumePath     = SourceVolumePath;
RegistrationTransforms.TargetVolumePath     = TargetVolumePath;

%% look for registration in database
[ DBRegistrations, status ] = dbGetRegistrations(sourcePatientID, sourceVolumeID, targetPatientID, targetVolumeID, [], [], logFile);
assert(isequal(status, 1));


%% check in database if registration allready computed
if ( ~isempty(DBRegistrations) )
    DBRegistration = DBRegistrations(1);
else
    DBRegistration.sourcePatientID = sourcePatientID;
    DBRegistration.sourceVolumeID  = sourceVolumeID;
    DBRegistration.targetPatientID = targetPatientID;
    DBRegistration.targetVolumeID  = targetVolumeID;
    
    DBRegistration.affine          = 0;
    DBRegistration.nonRigid        = 0;
end


%% affine registration
dbLogMsg(['SERVER-INFO (' functionName '): fetching affine registration!'], logFile);
if ( DBRegistration.affine == 1 )
    RegistrationTransforms.affineFilePath = [VisceralPaths.regPath DBRegistration.affineFilename];
else
    
    tsp = timestamp();
    resTempPath    = [tempDir 'result_' num2str(tsp) '.nii'];
    
    % build nifty reg command
    command = ['reg_aladin ' ...
    '-ref ' TargetVolumePath ' '...
    '-flo ' SourceVolumePath ' '...
    '-res ' resTempPath ' '... 
    '-aff ' [VisceralPaths.regPath affineFileName ' '] ...
    '-ln '  num2str(AffineOptions.ln) ' -lp ' num2str(AffineOptions.lp) ' -nac;'];

    [status, ~] = system(command);
    
    if status==0
        RegistrationTransforms.affineFilePath = [VisceralPaths.regPath affineFileName];

        % cleanup
        system(['rm -f ' resTempPath]);

        % add affine registration to database
        DBRegistration.affine = 1;
        DBRegistration.affineFilename  = affineFileName;
                                    
        status = dbAddRegistration(sourcePatientID, sourceVolumeID, targetPatientID, targetVolumeID, DBRegistration.affineFilename,[], 1, 0, logFile);
        assert(isequal(status, 1));
    else
        disp('affine failed');
    end
end


%% return if only affine registration is required
if ( affineOnly ); return; end


%% nonrigid registration
dbLogMsg(['SERVER-INFO (' functionName '): fetching non-rigid registration!'], logFile);
if ( DBRegistration.nonRigid == 1 )
    
    RegistrationTransforms.cppNiiFilePath = [VisceralPaths.regPath DBRegistration.cppFilename];

else
    tsp = timestamp();
    resTempPath    = [tempDir 'result_' num2str(tsp) '.nii'];

    % compute nonrigid registration
    command = ['reg_f3d ' ...
    '-ref ' TargetVolumePath ' '...
    '-flo ' SourceVolumePath ' '...
    '-res ' resTempPath ' '...
    '-cpp ' [VisceralPaths.regPath cppFilename] ' '];

    if ~isempty (RegistrationTransforms.affineFilePath)
        command = [command '-aff ' RegistrationTransforms.affineFilePath ' '];
    end
    
    if useGPU
        command = [command '-gpu ' ];
    end
    
    command = [command ...
    '-ln ' num2str(NROptions.ln) ' '...
    '-lp ' num2str(NROptions.lp) ' '...
    '-sx ' num2str(NROptions.sx) ' '];

    if isfield(NROptions,'sy')
        command = [command '-sy ' num2str(NROptions.sy) ' '];
    end
    if isfield(NROptions,'sz')
        command = [command '-sz ' num2str(NROptions.sz) ' '];
    end

    command = [command '-be ' num2str(NROptions.be) ' '...
    '-maxit ' num2str(NROptions.maxit)];

    [status, ~] = system(command);

    if status==0
        RegistrationTransforms.cppNiiFilePath = [VisceralPaths.regPath cppFilename];

        % update registration entry in database
        DBRegistration.nonRigid = 1;
        DBRegistration.cppFilename  = cppFilename;

        status = dbUpdateRegistration(DBRegistration, logFile);
        assert(isequal(status, 1));
    end
end
