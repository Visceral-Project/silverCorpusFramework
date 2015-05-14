function [ conn, status ] = dbOpenConnection( logFile )
%
% Author: Markus Krenn @ CIR Lab (Medical University of Vienna)
% email:  markus.krenn@meduniwien.ac.at
%

conn = database(‚DB_SCHEMA’, ‚USERNAME’, ‚PASSWORD, ...
    'com.mysql.jdbc.Driver', 'jdbc:mysql://127.0.0.1:3306/');

status = dbCheckConnStatus(conn, 0);

% display status msg
if ( status == 0 )
    dbLogMsg(['dbOpenConnection (WARNING): ' conn.Message], logFile);
else
    dbLogMsg('dbOpenConnection: DB Connection established!', logFile);
end
