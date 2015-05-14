function [ status ] = dbRemoveStructure( radLexID, logFile )
%
% Author: Markus Krenn@ CIR Lab (Medical University of Vienna)
% email:  markus.krenn@meduniwien.ac.at
%

functionName = 'dbRemoveStructure';

% establish db connection
[ conn, status ] = dbOpenConnection(logFile);

% check if connection is established
if ( status == 1 )
    
    % create sql statement
    sqlStatement = ['delete from structure where radlexid=' num2str(radLexID)];
    
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
if ( status == 1 ); dbLogMsg(['DB-INFO (' functionName '): structure removed!'], logFile, 1); end

dbLogMsg('', logFile);
