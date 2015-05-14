function [ status ] = dbAddAtlasSegmentation( sourcePatientID, sourceVolumeID, targetPatientID, targetVolumeID, structureID,performance,  logFile )
%
% Author: Markus Krenn @ CIR Lab (Medical University of Vienna)
% email:  markus.krenn@meduniwien.ac.at
%

functionName = 'dbAddAtlasSegmentation';

% establish db connection
[ conn, status ] = dbOpenConnection(logFile);

% check if connection is established
if ( status == 1 )
     
    % create sql statement
    sqlStatement = ['insert into atlasSegmentation (targetpatientid,targetvolumeid,sourcepatientid,sourcevolumeid,structureID,performance) ' ...
        'values ('  num2str(targetPatientID) ',' ...
        num2str(targetVolumeID) ',' ...
        num2str(sourcePatientID) ',' ...
        num2str(sourceVolumeID) ',' ...
        num2str(structureID) ',' ...
        num2str(performance)  ')'];
    
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
if ( status == 1 ); dbLogMsg(['DB-INFO (' functionName '): atlas segmentation added!'], logFile, 1); end
dbLogMsg('', logFile);
