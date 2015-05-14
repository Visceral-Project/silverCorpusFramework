function [ status ] = dbRemoveSilverCorpusSegmentation( patientID, volumeID, structureID, labelFusionTypeID, logFile )
%
% Author: Markus Krenn @ CIR Lab (Medical University of Vienna)
% email:  markus.krenn@meduniwien.ac.at
%

functionName = 'dbRemoveSilverCorpusSegmentation';

% establish db connection
[ conn, status ] = dbOpenConnection(logFile);

% check if connection is established
if ( status == 1 )
    
    % create sql statement
    sqlStatement = ['delete from silvercorpussegmentation where patientid=' num2str(patientID) ' and volumeid=' num2str(volumeID) ...
        ' and structureID=' num2str(structureID) ' and labelFusionTypeID=' num2str(labelFusionTypeID)];
    
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
if ( status == 1 ); dbLogMsg(['DB-INFO (' functionName '): silvercorpus segmentation removed!'], logFile, 1); end

dbLogMsg('', logFile);
