function [ TransformedLabelNii ] = propagateVolumeToTarget( RegistrationResults,VolumeOrPath)
%
% Author: Markus Krenn @ CIR Lab (Medical University of Vienna)
% email:  markus.krenn@meduniwien.ac.at
%
% Input: 
% -Registration Results originated from "getRegistrationTransforms" as
% -3D Volume or Path to a *.nii.gz file in the size of the source volume
%
% Output:
% Volume propagated to the target volume
%
    tempDir= 'niftyRegTemp';
    if ~exist(tempDir,'dir')
        mkdir(tempDir);
    end
    
    tsp = num2str(timestamp());
    tempFile = [tempDir filesep 'result_' tsp '.nii'];
        
    if ischar(VolumeOrPath) 
        % if VolumeOrPath is of type char, it points to a nifti file of the
        % volume to transform
        tempVolumePath = VolumeOrPath;
        cleanTempVolume = 0;
    else
        tmpNii = load_untouch_nii_gzip(RegistrationResults.SourceVolumePath);
        tmpNii.img = VolumeOrPath;
        tempVolumePath = [tempDir '/temp_' tsp '.nii'];
        save_untouch_nii_gzip(tmpNii,tempVolumePath);
        cleanTempVolume = 1;
    end
    command = ['reg_resample ' ...
        '-ref ' RegistrationResults.TargetVolumePath ' '...
        '-flo ' tempVolumePath ' '...
        '-cpp ' RegistrationResults.cppNiiFilePath ' '...
        '-res ' tempFile ' ' ...
        '-NN'];
    
    [status, ~] = system(command);
    
    resNii = load_untouch_nii(tempFile);
    
    if status == 0
        
        TransformedLabelNii = resNii;
        
        % cleanup
        system(['rm -r ' tempFile]);

        if cleanTempVolume
            system(['rm -r ' tempVolumePath]);
        end
    end
end