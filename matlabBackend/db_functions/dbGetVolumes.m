function [ DBVolumes, status ] = dbGetVolumes( patientID, volumeID, modality, bodyRegion, goldCorpus,silverCorpus,logFile )
%
% Author: Markus Krenn @ CIR Lab (Medical University of Vienna)
% email:  markus.krenn@meduniwien.ac.at
%

functionName = 'dbGetVolumes';

% init jave mysql path
if ( isempty(strfind(javaclasspath, 'mysql-connector-java-5.1.18-bin.jar')) )
    javaaddpath('res/mysql-connector-java-5.1.18-bin.jar');
end

% establish db connection
[ conn, status ] = dbOpenConnection(logFile);

% init result struct
DBVolumes = [];

% check if connection is established
if ( status == 1 )
    
    sqlStatement = 'select * from volume where patientID!="0"';
    
    % add constraints
    if ( ~isempty(patientID) ); sqlStatement = [sqlStatement ' and patientid="' patientID '"']; end
    if ( ~isempty(volumeID) ); sqlStatement = [sqlStatement ' and volumeid=' num2str(volumeID)]; end
    if ( ~isempty(modality) ); sqlStatement = [sqlStatement ' and modality="' modality '"']; end
    if ( ~isempty(bodyRegion) ); sqlStatement = [sqlStatement ' and bodyregion="' bodyRegion '"']; end
    if ( ~isempty(goldCorpus) ); sqlStatement = [sqlStatement ' and goldCorpus=' num2str(goldCorpus)]; end
    if ( ~isempty(silverCorpus) ); sqlStatement = [sqlStatement ' and silverCorpus=' num2str(silverCorpus)]; end
    
    % execute sql statement
    [ status, curs] = dbExecuteStatement(conn, sqlStatement, logFile);
    if ( status == 0 )
        dbLogMsg(['DB-WARNING (' functionName '): select statement failed!'], logFile);
        dbLogMsg('', logFile); return;
    end

    % fetch data
    newCurs = fetch(curs);
        
    %% post processing of results
    nRows = rows(newCurs);

    if ( nRows > 0 )

        DBVolumes = struct([]);
        
        for iRow = 1 : nRows
            DBVolumes(iRow).patientID  = newCurs.Data{iRow,1};
            DBVolumes(iRow).volumeID   = newCurs.Data{iRow,2};
            DBVolumes(iRow).modality   = newCurs.Data{iRow,3};
            DBVolumes(iRow).bodyRegion = newCurs.Data{iRow,4};
            DBVolumes(iRow).filename   = newCurs.Data{iRow,5};
            DBVolumes(iRow).goldCorpus =  newCurs.Data{iRow,6};
            DBVolumes(iRow).silverCorpus= newCurs.Data{iRow,7};
        end
    end

    % display that select was successfull
    if ( status == 1 ); dbLogMsg(['DB-INFO (' functionName '): ' num2str(nRows) ' volumes selected!'], logFile); end
    dbLogMsg('', logFile);
    
    % close db connection
    dbCloseConnection(conn, logFile);
else
    dbLogMsg(['DB-WARNING (' functionName '): no connection established!'], logFile);
end
