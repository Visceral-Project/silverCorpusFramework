function [ DBStructures, status ] = dbGetStructures( structureID, name, logFile)
%
% Author: Markus Krenn @ CIR Lab (Medical University of Vienna)
% email:  markus.krenn@meduniwien.ac.at
%

%% get data from db

functionName = 'dbGetStructures';
DBStructures = [];

% establish db connection
[ conn, status ] = dbOpenConnection(logFile);

% check if connection is established
if ( status == 1 )
    
    sqlStatement = 'select * from structure where 1=1';
    
    % add constraints
    if ( ~isempty(structureID) ); sqlStatement = [sqlStatement ' and structureID=' num2str(structureID)]; end
    if ( ~isempty(name) ); sqlStatement     = [sqlStatement ' and name="' name '"']; end

    
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
    
    DBStructures = struct([]);
    for iRow = 1 : nRows
    
        DBStructures(iRow).structureID = curs.Data{iRow,1};
        DBStructures(iRow).name     = curs.Data{iRow,2};
    end
end

% display that select was successfull
if ( status == 1 ); dbLogMsg(['DB-INFO (' functionName '): ' num2str(nRows) ' structures selected!'], logFile); end
dbLogMsg('', logFile);
