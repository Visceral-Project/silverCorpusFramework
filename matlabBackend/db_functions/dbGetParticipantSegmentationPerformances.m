function [ performances, status ] = dbGetParticipantSegmentationPerformances( patientID, volumeID,modality, bodyRegion, structureID, ...
    participantID,  performance, logFile )
%
% Author: Markus Krenn @ CIR Lab (Medical University of Vienna)
% email:  markus.krenn@meduniwien.ac.at
%

%% get data from db
functionName = 'dbGetParticipantSegmentationPerformances';
performances = [];

% establish db connection
[ conn, status ] = dbOpenConnection(logFile);



% check if connection is established
if ( status == 1 )
    
  sqlStatement = 'select performance from fullParticipantSegmentation_view where 1=1';
    
    % add constraints
    if ( ~isempty(patientID) );     sqlStatement = [sqlStatement ' and patientid="' num2str(patientID) '"']; end
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
    
    performances = [];
    for iRow = 1 : nRows
        performances = [performances curs.Data{iRow,1} ];
    end
end

% display that select was successfull
if ( status == 1 ); dbLogMsg(['DB-INFO (' functionName '): ' num2str(nRows) ' participant performances selected!'], logFile); end
dbLogMsg('', logFile);
