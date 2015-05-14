function [ timestamp ] = getTimestamp()
%GETTIMESTAMP Summary of this function goes here
%   Detailed explanation goes here


    c = clock;
    timestamp = [num2str(c(1)) '_' num2str(c(2)) '_' num2str(c(3)) '_' num2str(c(4)) '_' num2str(c(5))];

end

