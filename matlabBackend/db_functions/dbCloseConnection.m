function [ status ] = dbCloseConnection( conn, logFile )
%
% Author: Markus Krenn @ CIR Lab (Medical University of Vienna)
% email:  markus.krenn@meduniwien.ac.at
%


close(conn);
status = ~dbCheckConnStatus(conn, 0);

% display status msg
if( status == 0 )
    dbLogMsg('dbCloseConnection (WARNING): DB Connection can not be closed!', logFile);
else
    dbLogMsg('dbCloseConnection: DB Connection closed!', logFile);
end
