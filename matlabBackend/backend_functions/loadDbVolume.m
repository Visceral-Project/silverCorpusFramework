% [ VolumeNii ] = loadDbVolume( DBVolume, VisceralPaths )
function [ VolumeNii ] = loadDbVolume( DBVolume, VisceralPaths, mode )
%
% Author: Matthias Dorfer @ CIR Lab (Medical University of Vienna)
% email:  matthias.dorfer@meduniwien.ac.at
%

if ( nargin < 3 ); mode = 'std'; end

switch ( mode )
    case 'std'
        VolumeNii = load_nii_gzip( [VisceralPaths.volumePath DBVolume.filename] );
    case 'untouch'
        VolumeNii = load_untouch_nii_gzip( [VisceralPaths.volumePath DBVolume.filename] );
end
