function [ status ] = dbUpdateParticipantSegmentation( DBParticipantSegmentation, logFile )
%
% Author: Markus Krenn@ CIR Lab (Medical University of Vienna)
% email:  markus.krenn@meduniwien.ac.at
%

functionName = 'dbUpdateParticipantSegmentation';

% establish db connection
[ conn, status ] = dbOpenConnection(logFile);

if isfield(DBParticipantSegmentation,'newVolumeID')
   newVolumeID = DBParticipantSegmentation.newVolumeID; 
    
else
    newVolumeID = DBParticipantSegmentation.volumeID;
end

% check if connection is established
if ( status == 1 )
    
    % create sql statement
    sqlStatement = ['update participantSegmentation ' ...
        'set patientID="' DBParticipantSegmentation.patientID '", ' ...
        'volumeID=' num2str(newVolumeID) ',' ...
        'participantid= "' DBParticipantSegmentation.participantID '",' ...
        'performance=' num2str(DBParticipantSegmentation.dice) ',' ...
        'filename="' DBParticipantSegmentation.filename '",' ...
        ' where patientID="' DBParticipantSegmentation.patientID '"'...
        ' and volumeID=' num2str(DBParticipantSegmentation.volumeID) ...
        ' and radlexID=' num2str(DBParticipantSegmentation.radlexID) ...
        ' and participantid like "' DBParticipantSegmentation.participantID '"' ];
    
    % execute sql statement
    status = dbExecuteStatement(conn, sqlStatement, logFile);
    if ( status == 0 )
        dbLogMsg(['DB-WARNING (' functionName '): update failed!'], logFile);
        dbLogMsg('', logFile); return;
    end
    
    % commit changes
    status = dbCommit(conn, logFile);
    
    if ( status == 0 )
        dbLogMsg(['DB-WARNING (' functionName '): commit failed!'], logFile);
        dbLogMsg('', logFile); return;
    end
    
    dbCloseConnection(conn, logFile);
else
    dbLogMsg(['DB-WARNING (' functionName '): no connection established!'], logFile);
end

% display that insert was successfull
if ( status == 1 ); dbLogMsg(['DB-INFO (' functionName '): participant segmentation updated!'], logFile, 1); end
dbLogMsg('', logFile);

