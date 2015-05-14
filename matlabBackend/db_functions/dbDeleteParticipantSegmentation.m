function status = dbDeleteParticipantSegmentation(DBParticipantSegmentation, logFile)
%
% Author: Markus Krenn @ CIR Lab (Medical University of Vienna)
% email:  markus.krenn@meduniwien.ac.at
%

%% get data from db

functionName = 'dbDeleteParticipantSegmentation';


% establish db connection
[ conn, status ] = dbOpenConnection(logFile);

% check if connection is established
if ( status == 1 )
    
    sqlStatement = 'delete from participantsegmentation where ';
    sqlStatement = [sqlStatement 'patientID like "' num2str(DBParticipantSegmentation.patientID) '"'];
    sqlStatement = [sqlStatement ' and volumeid = ' num2str(DBParticipantSegmentation.volumeID)];
    sqlStatement = [sqlStatement ' and structureID = ' num2str(DBParticipantSegmentation.structureID)];
    sqlStatement = [sqlStatement ' and participantid like "' DBParticipantSegmentation.participantID '"'];
    
    % execute sql statement
    [ status, curs] = dbExecuteStatement(conn, sqlStatement, logFile);
    if ( status == 0 )
        dbLogMsg(['DB-WARNING (' functionName '): select statement failed!'], logFile);
        dbLogMsg('', logFile); return;
    end
    
  
    dbCloseConnection(conn, logFile);
else
    dbLogMsg(['DB-WARNING (' functionName '): no connection established!'], logFile);
end
end