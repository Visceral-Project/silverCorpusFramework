function [ status ] = dbUpdateRegistration( DBRegistration, logFile )
%
% Author: Markus Krenn @ CIR Lab (Medical University of Vienna)
% email:  markus.krenn@meduniwien.ac.at
%

functionName = 'dbUpdateRegistration';

% establish db connection
[ conn, status ] = dbOpenConnection(logFile);

% check if connection is established
if ( status == 1 )
    
    % create sql statement
    sqlStatement = 'update registration set ';
    if DBRegistration.affine
        sqlStatement = [ sqlStatement 'affineFileName="' DBRegistration.affineFilename '",'];
    end
    
    sqlStatement = [ sqlStatement 'cppNiiFilename="' DBRegistration.cppFilename '",'];
    
    if DBRegistration.affine
        sqlStatement = [ sqlStatement 'affine=' num2str(DBRegistration.affine) ','];
    end
    sqlStatement = [ sqlStatement 'nonrigid=' num2str(DBRegistration.nonRigid) ...
        ' where sourcePatientID=' num2str(DBRegistration.sourcePatientID) ...
        ' and sourceVolumeID=' num2str(DBRegistration.sourceVolumeID) ...
        ' and targetPatientID=' num2str(DBRegistration.targetPatientID) ...
        ' and targetVolumeID=' num2str(DBRegistration.targetVolumeID)];
    
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
if ( status == 1 ); dbLogMsg(['DB-INFO (' functionName '): registration updated!'], logFile, 1); end

dbLogMsg('', logFile);
