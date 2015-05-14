function [ status ] = dbAddVolume( patientID, volumeID, modality, bodyRegion, fileName,goldCorpus,silverCorpus, logFile )
%
% Author: Markus Krenn @ CIR Lab (Medical University of Vienna)
% email:  markus.krenn@meduniwien.ac.at
%

functionName = 'dbAddVolume';

% establish db connection
[ conn, status ] = dbOpenConnection(logFile);

if isempty(goldCorpus); goldCorpus=0;end
if isempty(silverCorpus); silverCorpus=0;end

% check if connection is established
if ( status == 1 )
    
    % create sql statement
    sqlStatement = ['insert into volume (patientid, volumeid, modality, bodyregion, filename, goldCorpus, silverCorpus) values ("' ... 
        patientID '",' num2str(volumeID) ',"' modality '","' bodyRegion '","'  fileName '",' num2str(goldCorpus) ',' num2str(silverCorpus) ')'];
    
    % execute sql statement
    status = dbExecuteStatement(conn, sqlStatement, logFile);
    if ( status == 0 )
        dbLogMsg(['DB-WARNING (' functionName '): insert failed!'], logFile);
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

% display that insert was successfull
if ( status == 1 ); dbLogMsg(['DB-INFO (' functionName '): volume added!'], logFile, 1); end
dbLogMsg('', logFile);
