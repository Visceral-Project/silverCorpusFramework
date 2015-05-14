function [ DBRegistrations, status ] = dbGetRegistrations( sourcePatientID, sourceVolumeID, targetPatientID, targetVolumeID, affine, nonRigid, logFile )
%
% Author: Markus Krenn @ CIR Lab (Medical University of Vienna)
% email:  markus.krenn@meduniwien.ac.at
%

functionName = 'dbGetRegistrations';

% init jave mysql path
if ( isempty(strfind(javaclasspath, 'mysql-connector-java-5.1.18-bin.jar')) )
    javaaddpath('res/mysql-connector-java-5.1.18-bin.jar');
end

% init result struct
DBRegistrations = [];

% establish db connection
[ conn, status ] = dbOpenConnection(logFile);

% check if connection is established
if ( status == 1 )
    
    sqlStatement = 'select * from registration where 1=1';
    
    % add constraints
    if ( ~isempty(sourcePatientID) ); sqlStatement = [sqlStatement ' and sourcePatientID=' num2str(sourcePatientID)]; end
    if ( ~isempty(sourceVolumeID) ); sqlStatement = [sqlStatement ' and sourceVolumeID=' num2str(sourceVolumeID)]; end
    if ( ~isempty(targetPatientID) ); sqlStatement = [sqlStatement ' and targetPatientID=' num2str(targetPatientID)]; end
    if ( ~isempty(targetVolumeID) ); sqlStatement = [sqlStatement ' and targetVolumeID=' num2str(targetVolumeID)]; end
    if ( ~isempty(affine) ); sqlStatement = [sqlStatement ' and affine=' num2str(affine)]; end
    if ( ~isempty(nonRigid) ); sqlStatement = [sqlStatement ' and nonRigid=' num2str(nonRigid)]; end
    
    % execute sql statement
    [ status, curs] = dbExecuteStatement(conn, sqlStatement, logFile);
    if ( status == 0 )
        dbLogMsg(['DB-WARNING (' functionName '): select statement failed!'], logFile);
        dbLogMsg('', logFile); return;
    end
    
    % fetch data
    curs = fetch(curs);
    
    % post processing of results
    nRows = rows(curs);

    if ( nRows > 0 )

        DBRegistrations = struct([]);
        for iRow = 1 : nRows

            DBRegistrations(iRow).sourcePatientID = curs.Data{iRow,1};
            DBRegistrations(iRow).sourceVolumeID  = curs.Data{iRow,2};
            DBRegistrations(iRow).targetPatientID = curs.Data{iRow,3};
            DBRegistrations(iRow).targetVolumeID  = curs.Data{iRow,4};
            DBRegistrations(iRow).affineFilename  = curs.Data{iRow,5};
            DBRegistrations(iRow).cppFilename  = curs.Data{iRow,6};
            DBRegistrations(iRow).affine  = curs.Data{iRow,7};
            DBRegistrations(iRow).nonRigid  = curs.Data{iRow,8};

        end
    end

    % display that select was successfull
    if ( status == 1 ); dbLogMsg(['DB-INFO (' functionName '): ' num2str(nRows) ' registrations selected!'], logFile); end
    dbLogMsg('', logFile);
    
    % close db connection
    dbCloseConnection(conn, logFile);
else
    dbLogMsg(['DB-WARNING (' functionName '): no connection established!'], logFile);
end
