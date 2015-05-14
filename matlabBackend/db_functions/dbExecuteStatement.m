function [ status, curs ] = dbExecuteStatement(conn, sqlStatement, logFile)
%
% Author: Matthias Dorfer @ CIR Lab (Medical University of Vienna)
% email:  matthias.dorfer@meduniwien.ac.at
%

% execute statement
curs = exec(conn, sqlStatement);
    
% check if execution worked correct
status = isempty(curs.Message);

% display error message
if ( status == 0 )
    dbLogMsg(['dbExecuteStatement (WARNING): ' curs.Message], logFile);
else
    dbLogMsg('dbExecuteStatement: SQL Statement executed correctly!', logFile);
end
