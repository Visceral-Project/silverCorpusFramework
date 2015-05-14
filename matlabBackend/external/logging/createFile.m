function [ fid ] = createFile(fileName, filePath)
%INITIALIZELOGFILE Summary of this function goes here
%   Detailed explanation goes here
   % logName = 'calcMiniatures';
    
   if ~exist(filePath)==7
        mkdir(filePath);
   end
   fullFilePath = [filePath fileName ];
   fid = fopen(fullFilePath,'w');
end

