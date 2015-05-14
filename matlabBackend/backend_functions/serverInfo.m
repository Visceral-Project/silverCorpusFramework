function [ ] = serverInfo(inofMsg, logFile)
%
% Author: Matthias Dorfer @ CIR Lab (Medical University of Vienna)
% email:  matthias.dorfer@meduniwien.ac.at
%

dbLogMsg('', logFile,1);
dbLogMsg(['### SERVER(INFO): ' inofMsg], logFile,1);