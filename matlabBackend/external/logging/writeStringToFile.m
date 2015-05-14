function [ success ] = writeStringToFile( message, fid )
%WRITEMESSAGE Summary of this function goes here
%   Detailed explanation goes here

    try
        %fprintf(message);
        if (nargin > 1)
            fprintf(fid,message);
        end
        success = 1;
    catch
       success = 0; 
    end

end

