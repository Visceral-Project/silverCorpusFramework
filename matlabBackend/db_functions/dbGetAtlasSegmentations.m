function [ AtlasSegmentations, status ] = dbGetAtlasSegmentations( patientID, volumeID, structureID, performance, logFile )
%
% Author: Markus Krenn @ CIR Lab (Medical University of Vienna)
% email:  markus.krenn@meduniwien.ac.at
%

%% get data from db
functionName = 'dbGetAtlasSegmentations';
AtlasSegmentations = [];

% establish db connection
[ conn, status ] = dbOpenConnection(logFile);

% check if connection is established
if ( status == 1 )
    
  sqlStatement = 'select * from atlasSegmentation where 1=1';
    
    % add constraints
    if ( ~isempty(patientID) );     sqlStatement = [sqlStatement ' and sourcePatientID="' num2str(patientID) '"']; end
    if ( ~isempty(volumeID) );      sqlStatement = [sqlStatement ' and sourceVolumeID=' num2str(volumeID)]; end
    if ( ~isempty(structureID) );      sqlStatement = [sqlStatement ' and structureID=' num2str(structureID)]; end

    if ( ~isempty(performance) )
        sqlStatement = [sqlStatement ' and performance>=' num2str(performance(1))];
        sqlStatement = [sqlStatement ' and performance<=' num2str(performance(2))];
    end
  
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
    
    AtlasSegmentations = [];
    for iRow = 1 : nRows
        AtlasSegmentations(end+1).sourcePatientID   =  curs.Data{iRow,1} ;
        AtlasSegmentations(end).sourceVolumeID    =  curs.Data{iRow,2} ;
        AtlasSegmentations(end).targetPatientID   =  curs.Data{iRow,3} ;
        AtlasSegmentations(end).targetVolumeID    =  curs.Data{iRow,4} ;
        AtlasSegmentations(end).structureID       =  curs.Data{iRow,5} ;
        AtlasSegmentations(end).performance       =  curs.Data{iRow,6} ;
    end
end

% display that select was successfull
if ( status == 1 ); dbLogMsg(['DB-INFO (' functionName '): ' num2str(nRows) ' participant results selected!'], logFile); end
dbLogMsg('', logFile);
