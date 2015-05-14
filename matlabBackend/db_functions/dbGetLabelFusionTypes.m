function [ DBLabelFusionTypes, status ] = dbGetLabelFusionTypes( id, logFile )
%
% Author: Markus Krenn @ CIR Lab (Medical University of Vienna)
% email:  markus.krenn@meduniwien.ac.at
%

%% get data from db
functionName = 'dbGetLabelFusionTypes';
DBLabelFusionTypes = [];

% establish db connection
[ conn, status ] = dbOpenConnection(logFile);


% check if connection is established
if ( status == 1 )
    
    sqlStatement = 'select * from labelfusiontype where 1=1';
    
    % add constraints
    if ( ~isempty(id) );     sqlStatement = [sqlStatement ' and labelfusiontypeID=' num2str(id)]; end
    

    
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
    
    DBLabelFusionTypes = struct([]);
    for iRow = 1 : nRows    
        DBLabelFusionTypes(iRow).labelFusionTypeID     = curs.Data{iRow,1};
        DBLabelFusionTypes(iRow).description           = curs.Data{iRow,2};
     end
end

% display that select was successfull
if ( status == 1 ); dbLogMsg(['DB-INFO (' functionName '): ' num2str(nRows) ' label fusion types selected!'], logFile); end
dbLogMsg('', logFile);


end

