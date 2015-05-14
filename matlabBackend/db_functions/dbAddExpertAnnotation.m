function [ status ] = dbAddExpertAnnotation(patientID, volumeID, structureID, filename, logFile)
%
% Author: Markus Krenn @ CIR Lab (Medical University of Vienna)
% email:  markus.krenn@meduniwien.ac.at
%

functionName = 'dbAddExpertAnnotation';


% establish db connection
[ conn, status ] = dbOpenConnection(logFile);


% check if connection is established
if ( status == 1 )
                                                
    sqlStatement = ['insert into ExpertAnnotation (PatientID, VolumeID, StructureID, filename) ' ...
        'values ("' num2str(patientID) '" ,' num2str(volumeID) ' ,' num2str(structureID) ', "' filename '")'];
            
    % execute sql statement
    [ status, curs ]  = dbExecuteStatement(conn, sqlStatement, logFile);
    if ( status == 0 )
        dbLogMsg(['DB-WARNING (' functionName '): insert failed!'], logFile);
        dbLogMsg('', logFile); return;
    end
    
    dbCloseConnection(conn, logFile);
else
    dbLogMsg(['DB-WARNING (' functionName '): no connection established!'], logFile);
end

% display that insert was successfull
if ( status == 1 ); dbLogMsg(['DB-INFO (' functionName '): new entries successfully inserted!'], logFile, 1); end

dbLogMsg('', logFile);
