function [ status ] = dbAddRegistration( sourcePatientID, sourceVolumeID, targetPatientID, targetVolumeID, affineFileName,cppFilename, affine, nonRigid, logFile )
%
% Author: Matthias Dorfer @ CIR Lab (Medical University of Vienna)
% email:  matthias.dorfer@meduniwien.ac.at
%

functionName = 'dbAddRegistration';

% establish db connection
[ conn, status ] = dbOpenConnection(logFile);

% check if connection is established
if ( status == 1 )
    
    if isempty(affineFileName); affineFileName = '';end;
    if isempty(cppFilename); cppFilename = '';end;
    
    % create sql statement
    sqlStatement = 'insert into registration (sourcepatientid,sourcevolumeid,targetpatientid,targetvolumeid,affinefilename, ';
    
    if ~isempty(cppFilename)
        sqlStatement = [sqlStatement 'cppfilename,'];    
    end
    
    sqlStatement = [sqlStatement ' affine, nonrigid) values (' ,...
        num2str(sourcePatientID) ',' num2str(sourceVolumeID) ',' num2str(targetPatientID) ',' num2str(targetVolumeID) ',"' affineFileName '",'];
    
    if ~isempty(cppFilename)
        
         sqlStatement = [sqlStatement '"' cppFilename '",'];
    end
    
    sqlStatement = [sqlStatement num2str(affine) ',' num2str(nonRigid) ')'];
    
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
if ( status == 1 ); dbLogMsg(['DB-INFO (' functionName '): registration added!'], logFile, 1); end
dbLogMsg('', logFile);
