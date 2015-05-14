function [ DBManAnnotations, status ] = dbGetExpertAnnotation( patientID, volumeID, structureID,  logFile)
%
% Author: Markus Krenn @ CIR Lab (Medical University of Vienna)
% email:  markus.krenn@meduniwien.ac.at
%

%% get data from db

functionName = 'dbGetExptertAnnotation';
DBManAnnotations = [];

% establish db connection
[ conn, status ] = dbOpenConnection(logFile);

% check if connection is established
if ( status == 1 )
    sqlStatement = 'select * from ExpertAnnotation where 1=1';

    % add constraints
    if ( ~isempty(patientID) );         sqlStatement = [sqlStatement ' and PatientID like "' num2str(patientID) '"']; end
    if ( ~isempty(volumeID) );          sqlStatement = [sqlStatement ' and VolumeID=' num2str(volumeID)]; end
    if ( ~isempty(structureID) );       sqlStatement = [sqlStatement ' and StructureID=' num2str(structureID)]; end
 
    % execute sql statement
    [ status, curs] = dbExecuteStatement(conn, sqlStatement, logFile);
    if ( status == 0 )
        dbLogMsg(['DB-WARNING (' functionName '): select statement failed!'], logFile);
        dbLogMsg('', logFile); return;
    end
    
    % fetch data
    curs = fetch(curs);   
    dbCloseConnection(conn, logFile);
else
    dbLogMsg(['DB-WARNING (' functionName '): no connection established!'], logFile);
end


%% post processing of results
nRows = rows(curs);
if ( nRows > 0 )
    
    DBManAnnotations = struct([]);
    for iRow = 1 : nRows
        
        DBManAnnotations(iRow).patientID          = curs.Data{iRow,1}; 
        DBManAnnotations(iRow).volumeID           = curs.Data{iRow,2}; 
        DBManAnnotations(iRow).structureID        = curs.Data{iRow,3};
        DBManAnnotations(iRow).filename           = curs.Data{iRow,4}; 
    end
end

% display that select was successfull
if ( status == 1 ); dbLogMsg(['DB-INFO (' functionName '): ' num2str(nRows) ' annotations selected!'], logFile); end
dbLogMsg('', logFile);
