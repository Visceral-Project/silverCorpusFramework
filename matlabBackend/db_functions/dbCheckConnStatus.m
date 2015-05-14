function [ status ] = dbCheckConnStatus( conn, showMsg, logFile )
%
% Author: Markus Krenn @ CIR Lab (Medical University of Vienna)
% email:  markus.krenn@meduniwien.ac.at
%


% get status
status = isconnection(conn);

if ( ~showMsg ); return; end;

% check for open connection
if( status )
    dbLogMsg('dbCheckConnStatus: DB Connection open!', logFile);
else
    dbLogMsg('dbCheckConnStatus: DB Connection closed!', logFile);
end
