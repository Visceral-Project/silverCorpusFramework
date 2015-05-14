classdef ioHelpers
%IOHELPERS
%
%   ioHelper class holds several helper funtions for io processing
%
%   A.Burner 2009: Work in progress
    
methods(Static)

function dirs = listDirs( directory )
% function dirs = listDirs( directory )
%
% returns a list of directories in the given directory

    dirs=dir(directory);

    % remove '.' and '..' entries
    dirs(strmatch('..',char(dirs.name),'exact'))=[];
    dirs(strmatch('.',char(dirs.name),'exact'))=[];

    % list the names only
    dirs={dirs([dirs.isdir]).name}.';
end

function files = listFiles( directory )
% function dirs = listFiles( directory )
%
% returns a list of files in the given directory

    files=dir(directory);

    % remove '.' and '..' entries
    files(strmatch('..',char(files.name),'exact'))=[];
    files(strmatch('.',char(files.name),'exact'))=[];

    % list the names only
    files={files(~[files.isdir]).name}.';
end

function sortedList = sortListByIndex( list, charIndex )
% sorts a list by ignoring the first <charIndex-1> characters
    swapped=true;
    while (swapped)
       swapped=false;
       for i=1:numel(list)-1

          a=cell2mat(list(i));
          b=cell2mat(list(i+1));
          a=a(charIndex:end);
          b=b(charIndex:end);
          if str2num(a)>str2num(b)
             swapped=true;
             s=list(i);
             list(i)=list(i+1);
             list(i+1)=s;
          end
       end
    end
    sortedList=list;
end

function sortedList = sortList( list )
% sorts a list: sortlist( ['I10', 'I100', 'I20'], 2 ) => ['I10', 'I20', 'I100']

    % count the characters
    t=cell2mat(list(numel(list)/uint8(2))); %take the center element, then there is no a* file ;)
    charIndex=1;
    while (charIndex<=numel(t))
       if (numel(str2num(t(charIndex:end)))>0)
           break
       end
       charIndex=charIndex+1;
    end

    if (charIndex==1 || charIndex>numel(t))
        sortedList=list;
        return;
    end

    sortedList=ioHelpers.sortListByIndex(list, charIndex);
end

function exists = existsDir( directory )
% returns whether a directory exists or not
   exists = exist(directory, 'dir')==7;
end

function created = createDir( directory )
% creates a directory if it does not exist    
   if (~ioHelpers.existsDir(directory))
      created = mkdir(directory);
   end
end

function exists = existsFile( filename )
% returns whether a file exists
    exists = exist( filename, 'file' );
end

function content = inspectMAT( filename )
% returns the content of a matlab file without loading it
    content=whos( '-file', filename ); 
end

function hostname = getHostName()
% returns the hostname of the current machine in lowercase
   [ret, hostname] = system('hostname');

    if ret ~= 0,
       if ispc
          hostname = getenv('COMPUTERNAME');
       else
          hostname = getenv('HOSTNAME');
       end
    end
    hostname = lower(hostname);
    hostname = deblank(hostname);
    
    subDomainIndex=strfind(hostname, '.');
    if (numel(subDomainIndex)>0) && (subDomainIndex(1)>1)
       hostname=hostname(1:subDomainIndex(1)-1);
    end
end

function username = getUserName()
% returns the username, logged in on the current machine in lowercase
    if ispc
        username = getenv('USERNAME');
    else
        username = getenv('USER');
    end
    username = lower(username);
end

function processID = getPID()
% returns the process id of the current machine    
    processID = feature('getPID');
end

function gzip( filename )
%function gzip( filename )
%
%   Function gzip compresses the given file by executing gzip

    os=computer;
    if ( strcmp( os(1:5), 'PCWIN' ) )
        system(['gzip -f9 "' filename '"']);
    else
        system(['gzip -f9 ' filename]);
    end    
end

function structString = struct2string ( aStruct, aExclude )
% returns in a form "(a-1)_(b-2)"

    pNames = fieldnames( aStruct );
    pValues = struct2cell( aStruct );
    
    structString='';
    for i=1:numel(pNames);
        if exist( 'aExclude', 'var' )
            if strncmp( aExclude, pNames{i}, numel(aExclude))
                continue
            end
        end
        value=pValues{i};
        
        if isnumeric(value)
           value=num2str(value); 
        end
        
        structString=[structString '(' pNames{i} '-' num2str(value) ')_']; %#ok<AGROW>
    end
    structString=structString(1:end-1);
end

function exportToFileTools( filename, data, numClasses )
% function exportToFileTools( filename, data, numClasses )
%
% Implemented to export data to MIForest

    fh = fopen( filename, 'w' );
    if isfloat(data)
        fprintf( fh, 'double\n' );
    else
        fprintf( fh, 'int\n' );
    end
    fprintf( fh, '%d %d %d\n', [size(data,1), size(data,2), numClasses] );
    fprintf( fh, 'dense\n' );   
    
    for d1=1:size( data, 1 )
        %for d2=1:size( data, 2 )
            if isfloat( data )
                fprintf( fh, '%f ',data(d1,:) );
            else
                fprintf( fh, '%d ',data(d1,:) );
            end
        %end
        fprintf( fh, '\n' );
    end
    
    fclose(fh);    
end

function data = importFromFileTools( filename )
% function data = importFromFileTools( filename )
%
% Implemented to import data from MIForest

    fh = fopen( filename, 'r' );

    datatype = fgetl(fh);
    [dim1, numClasses] = strtok(fgetl(fh), ' ');
    [dim2, numClasses] = strtok(numClasses, ' ');
    dim1=str2num(dim1); dim2=str2num(dim2); numClasses=str2num(numClasses);
    dense_dummy = fgetl(fh);
    i=1;
    row = fgetl(fh);
    while ischar(row)
        data(i,:)=str2num(row);
        row = fgetl(fh);
        i=i+1;
    end
    
    if sum(size(data)-[dim1 dim2])~=0
       error('dimensions do not match') 
    end
    
    if strcmp(datatype,'int')
       data=uint32(data); 
    end
    
    fclose(fh);    
end

end % methods

end % classdef
