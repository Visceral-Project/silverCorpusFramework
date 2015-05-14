function [ status ] = dbAddParticipantSegmentation( patientID, volumeID, radlexID, participantID, performance, filename,logFile )
%
% Author: Markus Krenn @ CIR Lab (Medical University of Vienna)
% email:  markus.krenn@meduniwien.ac.at
%

if isempty(performance); performance =-1;end

functionName = 'dbAddParticipantSegmentation';

% establish db connection
[ conn, status ] = dbOpenConnection(logFile);

% check if connection is established
if ( status == 1 )
    
    % create sql statement
    sqlStatement = ['insert into participantsegmentation (patientid, volumeid, radlexID, participantid, performance, filename) values ("' ...
        patientID '",' num2str(volumeID) ',' num2str(radlexID) ',"' participantID '",' ...
        num2str(performance) ',"' filename '")'];
    
    % execute sql statement
    status = dbExecuteStatement(conn, sqlStatement, logFile);
    if ( status == 0 )
        dbLogMsg(['DB-WARNING (' functionName '): insert failed!'], logFile);
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
if ( status == 1 ); dbLogMsg(['DB-INFO (' functionName '): participant segmentation added!'], logFile, 1); end
dbLogMsg('', logFile);
