function [ status ] = dbRemoveRegistration( sourcePatientID, sourceVolumeID, targetPatientID, targetVolumeID, logFile )
%
% Author: Markus Krenn @ CIR Lab (Medical University of Vienna)
% email:  markus.krenn@meduniwien.ac.at
%

functionName = 'dbRemoveRegistration';

% establish db connection
[ conn, status ] = dbOpenConnection(logFile);

% check if connection is established
if ( status == 1 )
    
    % create sql statement
    sqlStatement = ['delete from registration where sourcePatientID=' num2str(sourcePatientID) ' and sourceVolumeID=' num2str(sourceVolumeID), ...
        ' and targetPatientID=' num2str(targetPatientID) ' and targetVolumeID=' num2str(targetVolumeID)];
    
    % execute sql statement
    status = dbExecuteStatement(conn, sqlStatement, logFile);
    if ( status == 0 )
        dbLogMsg(['DB-WARNING (' functionName '): removing failed!'], logFile);
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

% display that removal was successfull
if ( status == 1 ); dbLogMsg(['DB-INFO (' functionName '): registration removed!'], logFile, 1); end

dbLogMsg('', logFile);
