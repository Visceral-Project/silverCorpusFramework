function [ DBPartSegmentations, status ] = dbGetParticipantSegmentation( patientID, volumeID,modality, bodyRegion, structureID, ...
    participantID,  performance,logFile )
%
% Author: Markus Krenn @ CIR Lab (Medical University of Vienna)
% email:  markus.krenn@meduniwien.ac.at
%

%% get data from db

functionName = 'dbGetParticipantSegmentation';
DBPartSegmentations = [];

% establish db connection
[ conn, status ] = dbOpenConnection(logFile);


% check if connection is established
if ( status == 1 )
    
    sqlStatement = 'select * from fullParticipantSegmentation_view where 1=1';
    
    % add constraints
    if ( ~isempty(patientID) );     sqlStatement = [sqlStatement ' and patientid=' num2str(patientID)]; end
    if ( ~isempty(volumeID) );      sqlStatement = [sqlStatement ' and volumeid=' num2str(volumeID)]; end
    if ( ~isempty(modality) );      sqlStatement = [sqlStatement ' and modality="' modality '"']; end
    if ( ~isempty(bodyRegion) );    sqlStatement = [sqlStatement ' and bodyregion="' bodyRegion '"']; end
    if ( ~isempty(structureID) );   sqlStatement = [sqlStatement ' and structureID=' num2str(structureID)]; end
    if ( ~isempty(participantID) ); sqlStatement = [sqlStatement ' and participantid like "' participantID '"']; end
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
    
    DBPartSegmentations = struct([]);
    for iRow = 1 : nRows
        
        DBPartSegmentations(iRow).patientID          = curs.Data{iRow,1};
        DBPartSegmentations(iRow).volumeID           = curs.Data{iRow,2};
        DBPartSegmentations(iRow).modality           = curs.Data{iRow,3};
        DBPartSegmentations(iRow).bodyRegion         = curs.Data{iRow,4};
        DBPartSegmentations(iRow).structureID        = curs.Data{iRow,5};
        DBPartSegmentations(iRow).participantID      = curs.Data{iRow,6};
        DBPartSegmentations(iRow).performance        = curs.Data{iRow,7};
        DBPartSegmentations(iRow).filename           = curs.Data{iRow,8};
        DBPartSegmentations(iRow).structureName      = curs.Data{iRow,9};
    end
end

% display that select was successfull
if ( status == 1 ); dbLogMsg(['DB-INFO (' functionName '): ' num2str(nRows) ' participant segmentations selected!'], logFile); end
dbLogMsg('', logFile);


end

