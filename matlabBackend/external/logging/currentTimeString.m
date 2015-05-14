function timeString = currentTimeString()

% create timestamp
    c = clock();
    h = num2str(c(4));
    m = num2str(c(5));
    s = num2str(round(c(6)));
    if (length(h) == 1); h = ['0' h]; end
    if (length(m) == 1); m = ['0' m]; end
    if (length(s) == 1); s = ['0' s]; end
    timeString = [num2str(c(1)) '-' num2str(c(2)) '-' num2str(c(3)) '|' h ':' m ':' s ];% create timestamp

    
end