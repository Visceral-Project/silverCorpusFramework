function [ oldimg ] = visualLog(path, image,text,mode,umaxres )
%
% Johannes Hofmannigner, j.hofmanninger@gmail.com
%
% Logging function for images. Allows to log image+text combination
%
% Parameter:
%   path  ... path to log file
%   image ... rgb or grayscale image
%   text ... log text
%   mode ... [append, new] append to logfile or starts new log
%   maxres ... maximum resolution for log file. limit is 5000 x 5000 px
%

maxres = [4000 1200];
if(exist('umaxres','var'))
    maxres(1) = min(umaxres(1),maxres(1));
    maxres(2) = min(umaxres(2),maxres(2));
end

new = 0;
if(exist('mode','var'))
    switch(mode)
        case 'append'
        case 'new'
            new = 1;
        otherwise
            error('visualLog... only ''new'' and ''append'' are allowed for mode parameter');
    end
end

[pathstr,file,ext] = fileparts(path);

if(~exist(pathstr,'file'))
    mkdir(pathstr);
end

%%
oldimg = [];

%%
if(new == 0)
    if(exist(path,'file'))
        oldimg = imread(path);
    end
end
if(max(oldimg(:))>1)
    oldimg = double(oldimg)./255;
end

oldimgsz = size(oldimg);
linefull = 0;
oldimgBW = zeros(size(oldimg,1),size(oldimg,2));
oldimgBW(sum(oldimg,3)==3) = 1;

linepos = 1;

if(~isempty(oldimgBW) && size(oldimg,2) == maxres(2)) %% if not empty and not first line
    linepos = (find(oldimgBW(:,end) ~= 1,1,'first')+1);
end

if(~isempty(oldimgBW) && find(oldimgBW(linepos+1,:) == 1,1,'last')+size(image,2) >= maxres(2))
    linefull = 1;
    if(size(oldimg,1)+size(image,1)>maxres(1))
        firstline = find((sum(oldimgBW,2))==maxres(2),1,'first');
        oldimg(1:firstline,:,:) = [];
        oldimgBW(1:firstline,:,:) = [];
    end
    oldimgsz = size(oldimg);
    
    oldimg(:,maxres(2),:) = 1;
    oldimg(end+1,:,:) = 1;
    linepos = oldimgsz(1)+2;
end

if(linefull)
    columnpos = 1;
else
    if(~isempty(oldimgBW))
        columnpos = find(oldimgBW(linepos,:) == 1,1,'last')+1;
    else
        columnpos = 1;
    end
end

imgText = addText(image,text); % plot text under image
imgText(:,end+1,1:3) = 1; % add white bar to check line end

oldimg(linepos:linepos+size(imgText,1)-1,columnpos:columnpos+size(imgText,2)-1,1:3) = imgText;

imwrite(oldimg,path,'png');


end

function imgText = addText(image,text)
imsize = size(image);
lineheight = 7; % lineheight in rendertext tool
letterwidth = 6; % letter size in rendertext tool

lettersPLine = floor(imsize(2)/letterwidth);
numLines = ceil(length(text)/lettersPLine);

imgText = image;
imgText(imsize(1)+lineheight*numLines,imsize(2)) = 0; %% add lines


for i = 1:numLines
    imgText=rendertext(imgText,text((i-1)*lettersPLine+1:min(i*lettersPLine,length(text))),[255 255 255], [imsize(1)+(i-1)*lineheight,1]);
end
end


function test
%%
img = rand(500,500);
text = 'this is a Test Text $%%&? why?){[';
bla = visualLog('~/tmp/testVisualLog.png',img,text,'new');

%%
img = rand(500,500);
text = 'this is a Test Text $%%&? why?){[';
bla = visualLog('~/tmp/testVisualLog.png',img,text,'append');
imshow(bla);





end
