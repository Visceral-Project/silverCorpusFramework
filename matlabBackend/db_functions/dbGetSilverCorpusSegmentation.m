function [ DBSilverCorpusSegmentations, status ] = dbGetSilverCorpusSegmentation( patientID, volumeID, modality, bodyRegion, structureID, ...
    labelFusionTypeID,  performance, logFile )
%
% Author: Markus Krenn @ CIR Lab (Medical University of Vienna)
% email:  markus.krenn@meduniwien.ac.at
%

%% get data from db

functionName = 'dbGetSilverCorpusSegmentation';
DBSilverCorpusSegmentations = [];

% establish db connection
[ conn, status ] = dbOpenConnection(logFile);

% check if connection is established
if ( status == 1 )
    
    sqlStatement = 'select * from fullSilverCorpusSegmentation_view where 1=1';
    
    % add constraints
    if ( ~isempty(patientID) );         sqlStatement = [sqlStatement ' and patientid=' num2str(patientID)]; end
    if ( ~isempty(volumeID) );          sqlStatement = [sqlStatement ' and volumeid=' num2str(volumeID)]; end
    if ( ~isempty(modality) );          sqlStatement = [sqlStatement ' and modality="' (modality) '" ']; end
    if ( ~isempty(bodyRegion) );        sqlStatement = [sqlStatement ' and bodyregion=' num2str(bodyRegion)]; end
    if ( ~isempty(structureID) );          sqlStatement = [sqlStatement ' and structureID=' num2str(structureID)]; end
    if ( ~isempty(labelFusionTypeID) ); sqlStatement = [sqlStatement ' and labelFusionTypeID=' num2str(labelFusionTypeID)]; end
    
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
    
    DBSilverCorpusSegmentations = struct([]);
    
    for iRow = 1 : nRows      
        DBSilverCorpusSegmentations(iRow).patientID          = curs.Data{iRow,1};
        DBSilverCorpusSegmentations(iRow).volumeID           = curs.Data{iRow,2};
        DBSilverCorpusSegmentations(iRow).modality           = curs.Data{iRow,3};
        DBSilverCorpusSegmentations(iRow).bodyRegion         = curs.Data{iRow,4};
        DBSilverCorpusSegmentations(iRow).radlexID           = curs.Data{iRow,5};
        DBSilverCorpusSegmentations(iRow).labelFusionTypeID  = curs.Data{iRow,6};
        DBSilverCorpusSegmentations(iRow).fileName           = curs.Data{iRow,7};
        DBSilverCorpusSegmentations(iRow).performance        = curs.Data{iRow,8};
        DBSilverCorpusSegmentations(iRow).labelFusionResults = curs.Data{iRow,9};
        DBSilverCorpusSegmentations(iRow).processingTime     = curs.Data{iRow,10};

    end
end

% display that select was successfull
if ( status == 1 ); dbLogMsg(['DB-INFO (' functionName '): ' num2str(nRows) ' silver corpus segmentations selected!'], logFile); end
dbLogMsg('', logFile);
