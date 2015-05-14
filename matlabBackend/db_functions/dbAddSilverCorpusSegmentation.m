function [ status ] = dbAddSilverCorpusSegmentation( patientID, volumeID, structureID, labelFusionTypeID, filename,performance,logFile )
%
% Author: Markus Krenn @ CIR Lab (Medical University of Vienna)
% email:  markus.krenn@meduniwien.ac.at
%

functionName = 'dbAddSilverCorpusSegmentation';

% establish db connection
[ conn, status ] = dbOpenConnection(logFile);

% check if connection is established
if ( status == 1 )
    
    if isempty(performance); performance = -1;end
    
    % create sql statement
    sqlStatement = 'insert into silvercorpusSegmentation (patientid, volumeid, structureID, labelfusiontypeid, filename';
    
    if ~isempty(performance); sqlStatement = [sqlStatement ',performance'];end

    sqlStatement= [ sqlStatement ' ) values ('...
        '"' patientID '",' ...
        num2str(volumeID) ',' ...
        num2str(structureID) ',' ...
        num2str(labelFusionTypeID) ',' ...
        '"' filename '"'];
    
    if ~isempty(performance); sqlStatement = [sqlStatement ',' num2str(performance)]; end
    
    sqlStatement= [ sqlStatement ' )'];
    
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
if ( status == 1 )
    dbLogMsg(['DB-INFO (' functionName '): silver corpus segmentation added!'], logFile, 1);
    
end
dbLogMsg('', logFile);
