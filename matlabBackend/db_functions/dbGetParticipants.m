function [ DBParticipants, status ] = dbGetParticipants( participantID, logFile )
%
% Author: Markus Krenn @ CIR Lab (Medical University of Vienna)
% email:  markus.krenn@meduniwien.ac.at
%

%% get data from db

functionName = 'dbGetParticipants';
DBParticipants = [];

% establish db connection
[ conn, status ] = dbOpenConnection(logFile);

% check if connection is established
if ( status == 1 )
    
    sqlStatement = 'select * from participant where 1=1';
    
    % add constraints
    if ( ~isempty(participantID) ); sqlStatement = [sqlStatement ' and participantID LIKE "' participantID '"']; end
    
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
    
    DBParticipants = struct([]);
    for iRow = 1 : nRows
    
        DBParticipants(iRow).participantID = curs.Data{iRow,1};
    end
end

% display that select was successfull
if ( status == 1 ); dbLogMsg(['DB-INFO (' functionName '): ' num2str(nRows) ' participants selected!'], logFile); end
dbLogMsg('', logFile);
